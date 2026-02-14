import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @State private var showSignOutConfirmation = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Infos utilisateur
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.displayName ?? "Utilisateur")
                                .font(.headline)
                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // MARK: - Déconnexion
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirmation = true
                    } label: {
                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                // MARK: - Erreur
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Profil")
            .confirmationDialog(
                "Se déconnecter ?",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Se déconnecter", role: .destructive) {
                    signOut()
                }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Vous serez redirigé vers l'écran de connexion.")
            }
        }
    }

    private func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthService())
}
