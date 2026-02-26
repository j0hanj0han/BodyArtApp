import SwiftUI
import AuthenticationServices
import CryptoKit

// MARK: - Unified Auth View

struct AuthView: View {
    @Environment(AuthService.self) private var authService

    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentNonce: String?

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        (isSignUp ? password.count >= 6 && password == confirmPassword : !password.isEmpty)
    }

    private var passwordMismatch: Bool {
        isSignUp && !confirmPassword.isEmpty && password != confirmPassword
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                AuthHeaderView(isSignUp: isSignUp)

                VStack(spacing: 14) {
                    LoginSocialButtonsView(
                        isSignUp: isSignUp,
                        isLoading: isLoading,
                        currentNonce: $currentNonce,
                        onFacebook: { Task { await signInWithFacebook() } },
                        onGoogle: { Task { await signInWithGoogle() } },
                        onApple: { result in Task { await handleAppleSignIn(result) } }
                    )

                    AuthDividerView(label: "ou par e-mail")

                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        SecureField(
                            isSignUp ? "Mot de passe (min. 6 caractères)" : "Mot de passe",
                            text: $password
                        )
                        .textFieldStyle(.roundedBorder)
                        .textContentType(isSignUp ? .newPassword : .password)

                        if isSignUp {
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

                    Button(action: { Task { await submit() } }) {
                        Group {
                            if isLoading { ProgressView() }
                            else { Text(isSignUp ? "Créer mon compte" : "Se connecter") }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isFormValid || isLoading)

                    Divider()

                    HStack {
                        Text(isSignUp ? "Déjà un compte ?" : "Pas encore de compte ?")
                            .foregroundStyle(.secondary)
                        Button(isSignUp ? "Se connecter" : "Créer un compte") {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                isSignUp.toggle()
                                password = ""
                                confirmPassword = ""
                            }
                        }
                    }
                    .font(.subheadline)
                }
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isSignUp)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Erreur", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let errorMessage { Text(errorMessage) }
        }
    }

    // MARK: - Actions

    private func submit() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch { errorMessage = error.localizedDescription }
    }

    private func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { try await authService.signInWithFacebook() }
        catch { errorMessage = error.localizedDescription }
    }

    private func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { try await authService.signInWithGoogle() }
        catch { errorMessage = error.localizedDescription }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let authorization = try result.get()
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else { throw AuthError.appleTokenMissing }
            try await authService.signInWithApple(
                idToken: idToken, rawNonce: nonce, fullName: credential.fullName
            )
        } catch { errorMessage = error.localizedDescription }
    }
}

// MARK: - Sub-views

struct AuthHeaderView: View {
    let isSignUp: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image("LaunchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            Text(isSignUp ? "Créer un compte" : "BodyArt974App")
                .font(.largeTitle).fontWeight(.bold)

            Text(isSignUp ? "Rejoignez BodyArt974App" : "Connectez-vous pour continuer")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

struct LoginSocialButtonsView: View {
    let isSignUp: Bool
    let isLoading: Bool
    @Binding var currentNonce: String?
    let onFacebook: () -> Void
    let onGoogle: () -> Void
    let onApple: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onFacebook) {
                Label("Continuer avec Facebook", systemImage: "f.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered).controlSize(.large).disabled(isLoading)

            Button(action: onGoogle) {
                Label("Continuer avec Google", systemImage: "g.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered).controlSize(.large).disabled(isLoading)

            SignInWithAppleButton(isSignUp ? .signUp : .signIn) { request in
                let nonce = AuthNonceHelper.randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = AuthNonceHelper.sha256(nonce)
            } onCompletion: { result in onApple(result) }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .disabled(isLoading)
        }
    }
}

struct AuthDividerView: View {
    let label: String

    var body: some View {
        HStack {
            Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
            Text(label).font(.caption).foregroundStyle(.secondary).fixedSize()
            Rectangle().fill(.secondary.opacity(0.3)).frame(height: 1)
        }
    }
}

// MARK: - Nonce Helpers (shared)

enum AuthNonceHelper {
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset: [Character] = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        )
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    static func sha256(_ input: String) -> String {
        let hashedData = SHA256.hash(data: Data(input.utf8))
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Image("Background").resizable().scaledToFill().ignoresSafeArea()
            AuthView()
        }
    }
    .environment(AuthService())
}
