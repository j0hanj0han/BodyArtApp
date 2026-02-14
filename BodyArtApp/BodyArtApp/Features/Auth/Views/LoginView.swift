import SwiftUI

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    @Binding var showSignUp: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            headerSection

            formSection

            loginButton

            dividerSection

            facebookButton

            googleButton

            Spacer()

            signUpSection
        }
        .padding()
        .navigationTitle("Connexion")
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
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("BodyArtApp")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Connectez-vous pour continuer")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var formSection: some View {
        VStack(spacing: 16) {
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

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(height: 1)

            Text("ou")
                .font(.caption)
                .foregroundStyle(.secondary)

            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(height: 1)
        }
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
}

#Preview {
    NavigationStack {
        LoginView(showSignUp: .constant(false))
            .environment(AuthService())
    }
}
