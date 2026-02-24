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

            VStack(spacing: 16) {
                headerSection

                VStack(spacing: 14) {
                    formSection
                    signUpButton
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

    // MARK: - Sections

    private var backButton: some View {
        HStack {
            Button(action: { showSignUp = false }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                    Text("Retour")
                }
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 3)
            }
            Spacer()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image("LaunchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text("Créer un compte")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.black)

            Text("Rejoignez BodyArtApp")
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.6))
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
                ProgressView().frame(maxWidth: .infinity)
            } else {
                Text("Créer mon compte").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!isFormValid || isLoading)
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
