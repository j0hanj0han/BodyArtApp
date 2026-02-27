import SwiftUI
import SwiftData
import FirebaseAuth
import FirebaseStorage
import PhotosUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.modelContext) private var modelContext
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var errorMessage: String?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isUploadingPhoto = false

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
                        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .navigationTitle("Profil")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onChange(of: selectedPhotoItem) { _, item in
                guard let item else { return }
                Task { await uploadPhoto(item) }
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
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        ProfilePhotoView(
                            url: authService.userPhotoURL,
                            displayName: authService.currentUser?.displayName,
                            size: 56
                        )
                        .overlay {
                            if isUploadingPhoto {
                                Circle().fill(.black.opacity(0.4))
                                ProgressView().tint(.white)
                            }
                        }
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 18))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.accentColor)
                            .background(Circle().fill(.white).padding(2))
                    }
                }
                .buttonStyle(.plain)
                .disabled(isUploadingPhoto)

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
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }

    private var accountActionsSection: some View {
        Section {
            Link(destination: URL(string: "https://j0hanj0han.github.io/BodyArtApp/privacy-policy.html")!) {
                Label("Politique de confidentialité", systemImage: "hand.raised")
            }
            Button(role: .destructive) {
                showSignOutConfirmation = true
            } label: {
                Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }

    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteAccountConfirmation = true
            } label: {
                Label("Supprimer le compte", systemImage: "person.crop.circle.badge.minus")
            }
        }
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }

    // MARK: - Photo Upload

    private func uploadPhoto(_ item: PhotosPickerItem) async {
        guard let uid = authService.currentUserUID,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data),
              let jpegData = uiImage.jpegData(compressionQuality: 0.8) else { return }

        isUploadingPhoto = true
        defer { isUploadingPhoto = false }
        errorMessage = nil

        do {
            let ref = Storage.storage().reference().child("profile_photos/\(uid).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await ref.putDataAsync(jpegData, metadata: metadata)
            let downloadURL = try await ref.downloadURL()

            let changeRequest = authService.currentUser?.createProfileChangeRequest()
            changeRequest?.photoURL = downloadURL
            try await changeRequest?.commitChanges()
            try await authService.reloadUser()

            let urlString = downloadURL.absoluteString
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.uid == uid }
            )
            if let localUser = try? modelContext.fetch(descriptor).first {
                localUser.photoURL = urlString
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Account Actions

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
