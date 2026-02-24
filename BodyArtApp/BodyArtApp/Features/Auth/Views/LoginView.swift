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
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 60)

                headerSection

                Spacer().frame(height: 8)

                // Carte frosted glass
                VStack(spacing: 14) {
                    appleButton
                    facebookButton
                    googleButton

                    dividerSection

                    formSection
                    loginButton

                    Divider()

                    signUpSection
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
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

            Text("BodyArtApp")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)

            Text("Connectez-vous pour continuer")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
    }

    private var appleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            let nonce = randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
        } onCompletion: { result in
            Task { await handleAppleSignIn(result) }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .disabled(isLoading)
    }

    private var facebookButton: some View {
        Button {
            Task { await signInWithFacebook() }
        } label: {
            HStack {
                Image(systemName: "f.circle.fill")
                Text("Continuer avec Facebook")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(isLoading)
    }

    private var googleButton: some View {
        Button {
            Task { await signInWithGoogle() }
        } label: {
            HStack {
                Image(systemName: "g.circle.fill")
                Text("Continuer avec Google")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(isLoading)
    }

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(height: 1)

            Text("ou par e-mail")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize()

            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(height: 1)
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

            SecureField("Mot de passe", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
        }
    }

    private var loginButton: some View {
        Button {
            Task { await signIn() }
        } label: {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Se connecter")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!isFormValid || isLoading)
    }

    private var signUpSection: some View {
        HStack {
            Text("Pas encore de compte ?")
                .foregroundStyle(.secondary)

            Button("Créer un compte") {
                showSignUp = true
            }
        }
        .font(.subheadline)
    }

    // MARK: - Actions

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signInWithFacebook()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        do {
            let authorization = try result.get()
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                throw AuthError.appleTokenMissing
            }
            try await authService.signInWithApple(
                idToken: idToken,
                rawNonce: nonce,
                fullName: credential.fullName
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in charset[Int(byte) % charset.count] }
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
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
