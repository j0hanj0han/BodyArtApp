import SwiftUI

struct SignUpView: View {
    @Environment(AuthService.self) private var authService
    @Binding var showSignUp: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }

    private var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 60)

                headerSection

                Spacer().frame(height: 8)

                // Carte frosted glass
                VStack(spacing: 14) {
                    formSection
                    signUpButton

                    Divider()

                    loginSection
                }
                .padding(24)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)

                Spacer().frame(height: 40)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

            Text("Rejoignez-nous")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)

            Text("Créez votre compte pour commencer")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
    }

    private var formSection: some View {
        VStack(spacing: 12) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            SecureField("Mot de passe (min. 6 caractères)", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)

            SecureField("Confirmer le mot de passe", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)

            if passwordMismatch {
                Text("Les mots de passe ne correspondent pas")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var signUpButton: some View {
        Button {
            Task { await signUp() }
        } label: {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Créer mon compte")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!isFormValid || isLoading)
    }

    private var loginSection: some View {
        HStack {
            Text("Déjà un compte ?")
                .foregroundStyle(.secondary)

            Button("Se connecter") {
                showSignUp = false
            }
        }
        .font(.subheadline)
    }

    // MARK: - Actions

    private func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Image("Background").resizable().scaledToFill().ignoresSafeArea()
            SignUpView(showSignUp: .constant(true))
        }
    }
    .environment(AuthService())
}
