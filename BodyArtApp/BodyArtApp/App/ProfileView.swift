import SwiftUI
import SwiftData
import FirebaseAuth

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.modelContext) private var modelContext
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background").resizable().scaledToFill().ignoresSafeArea()

                List {
                    profileHeaderSection
                    accountActionsSection
                    dangerZoneSection

                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .font(.footnote)
                        }
                        .listRowBackground(Rectangle().fill(.regularMaterial))
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .navigationTitle("Profil")
                .navigationBarTitleDisplayMode(.inline)
            }
            .confirmationDialog(
                "Se déconnecter ?",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Se déconnecter", role: .destructive) { signOut() }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Vous serez redirigé vers l'écran de connexion.")
            }
            .confirmationDialog(
                "Supprimer le compte ?",
                isPresented: $showDeleteAccountConfirmation,
                titleVisibility: .visible
            ) {
                Button("Supprimer définitivement", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Cette action est irréversible. Toutes vos données seront supprimées.")
            }
        }
    }

    // MARK: - Sections

    private var profileHeaderSection: some View {
        Section {
            HStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .symbolRenderingMode(.hierarchical)

                VStack(alignment: .leading, spacing: 4) {
                    Text(authService.currentUser?.displayName ?? "Utilisateur")
                        .font(.headline)
                    Text(authService.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var accountActionsSection: some View {
        Section {
            Button(role: .destructive) {
                showSignOutConfirmation = true
            } label: {
                Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteAccountConfirmation = true
            } label: {
                Label("Supprimer le compte", systemImage: "person.crop.circle.badge.minus")
            }
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    // MARK: - Actions

    private func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteAccount() async {
        guard let uid = authService.currentUserUID else { return }
        errorMessage = nil
        do {
            try await authService.deleteAccount()
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.uid == uid }
            )
            if let localUser = try? modelContext.fetch(descriptor).first {
                modelContext.delete(localUser)
            }
        } catch {
            let nsError = error as NSError
            if nsError.domain == AuthErrorDomain,
               nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                errorMessage = "Veuillez vous déconnecter et vous reconnecter avant de supprimer votre compte"
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ProfileView().environment(AuthService())
}
