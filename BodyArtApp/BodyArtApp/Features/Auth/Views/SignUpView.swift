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
        VStack(spacing: 0) {
            backButton
                .padding(.horizontal, 20)
                .padding(.top, 60)

            Spacer()

            VStack(spacing: 20) {
                SignUpHeaderView()

                VStack(spacing: 14) {
                    SignUpFormView(
                        email: $email,
                        password: $password,
                        confirmPassword: $confirmPassword,
                        passwordMismatch: passwordMismatch
                    )

                    Button(action: { Task { await signUp() } }) {
                        Group {
                            if isLoading { ProgressView() }
                            else { Text("Créer mon compte") }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let errorMessage { Text(errorMessage) }
        }
    }

    private var backButton: some View {
        HStack {
            Button(action: { showSignUp = false }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left").fontWeight(.semibold)
                    Text("Retour")
                }
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 3)
            }
            Spacer()
        }
    }

    private func signUp() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { try await authService.signUp(email: email, password: password) }
        catch { errorMessage = error.localizedDescription }
    }
}

// MARK: - Sub-views

struct SignUpHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("LaunchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            Text("Créer un compte")
                .font(.largeTitle).fontWeight(.bold)

            Text("Rejoignez BodyArtApp")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

struct SignUpFormView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    let passwordMismatch: Bool

    var body: some View {
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
