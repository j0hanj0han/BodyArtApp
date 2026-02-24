import SwiftUI
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    @Binding var showSignUp: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentNonce: String?

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                LoginHeaderView()

                VStack(spacing: 12) {
                    LoginSocialButtonsView(
                        isLoading: isLoading,
                        currentNonce: $currentNonce,
                        onFacebook: { Task { await signInWithFacebook() } },
                        onGoogle: { Task { await signInWithGoogle() } },
                        onApple: { result in Task { await handleAppleSignIn(result) } }
                    )

                    AuthDividerView(label: "ou par e-mail")

                    LoginFormView(email: $email, password: $password)

                    LoginPrimaryButton(
                        isLoading: isLoading,
                        isFormValid: isFormValid,
                        onTap: { Task { await signIn() } }
                    )

                    Divider()

                    HStack {
                        Text("Pas encore de compte ?").foregroundStyle(.secondary)
                        Button("Créer un compte") { showSignUp = true }
                    }
                    .font(.subheadline)
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

    // MARK: - Actions

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { try await authService.signIn(email: email, password: password) }
        catch { errorMessage = error.localizedDescription }
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

struct LoginHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("LaunchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            Text("BodyArtApp")
                .font(.largeTitle).fontWeight(.bold)

            Text("Connectez-vous pour continuer")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

struct LoginSocialButtonsView: View {
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

            SignInWithAppleButton(.signIn) { request in
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

struct LoginFormView: View {
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        VStack(spacing: 12) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            SecureField("Mot de passe", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
        }
    }
}

struct LoginPrimaryButton: View {
    let isLoading: Bool
    let isFormValid: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Group {
                if isLoading { ProgressView() }
                else { Text("Se connecter") }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!isFormValid || isLoading)
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
            LoginView(showSignUp: .constant(false))
        }
    }
    .environment(AuthService())
}
