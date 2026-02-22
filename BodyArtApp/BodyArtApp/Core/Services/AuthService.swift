import Foundation
import FirebaseAuth
import AuthenticationServices
import FacebookLogin
import GoogleSignIn
import FirebaseCore

@Observable
@MainActor
final class AuthService {
    private(set) var currentUser: FirebaseAuth.User?
    private(set) var authState: AuthState = .loading

    nonisolated(unsafe) private var authStateHandle: AuthStateDidChangeListenerHandle?

    enum AuthState: Equatable {
        case loading
        case authenticated
        case unauthenticated
    }

    init() {
        setupAuthStateListener()
    }

    deinit {
        let handle = authStateHandle
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    var currentUserUID: String? {
        currentUser?.uid
    }

    // MARK: - Auth State Listener

    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.authState = user != nil ? .authenticated : .unauthenticated
            }
        }
    }

    // MARK: - Email/Password Auth

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        currentUser = result.user
        authState = .authenticated
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        currentUser = result.user
        authState = .authenticated
    }

    // MARK: - Apple Auth

    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: rawNonce, fullName: fullName)
        let authResult = try await Auth.auth().signIn(with: credential)
        currentUser = authResult.user
        authState = .authenticated
    }

    // MARK: - Facebook Auth

    func signInWithFacebook() async throws {
        let loginManager = LoginManager()

        // Request Facebook login
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LoginManagerLoginResult, Error>) in
            loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthError.facebookLoginFailed)
                }
            }
        }

        guard !result.isCancelled else {
            throw AuthError.facebookLoginCancelled
        }

        guard let accessToken = AccessToken.current?.tokenString else {
            throw AuthError.facebookAccessTokenMissing
        }

        // Create Firebase credential from Facebook token
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)

        // Sign in to Firebase with Facebook credential
        let authResult = try await Auth.auth().signIn(with: credential)
        currentUser = authResult.user
        authState = .authenticated
    }

    // MARK: - Google Auth

    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.googleClientIDMissing
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.googlePresentationFailed
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.googleTokenMissing
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        currentUser = authResult.user
        authState = .authenticated
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        LoginManager().logOut()
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        authState = .unauthenticated
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        try await user.delete()
        LoginManager().logOut()
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        authState = .unauthenticated
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case facebookLoginFailed
    case facebookLoginCancelled
    case facebookAccessTokenMissing
    case googleClientIDMissing
    case googlePresentationFailed
    case googleTokenMissing
    case appleTokenMissing
    case appleSignInFailed
    case noCurrentUser

    var errorDescription: String? {
        switch self {
        case .facebookLoginFailed:
            return "La connexion Facebook a échoué"
        case .facebookLoginCancelled:
            return "La connexion Facebook a été annulée"
        case .facebookAccessTokenMissing:
            return "Token d'accès Facebook manquant"
        case .googleClientIDMissing:
            return "Configuration Google manquante"
        case .googlePresentationFailed:
            return "Impossible d'afficher la connexion Google"
        case .googleTokenMissing:
            return "Token Google manquant"
        case .appleTokenMissing:
            return "Token Apple manquant"
        case .appleSignInFailed:
            return "La connexion Apple a échoué"
        case .noCurrentUser:
            return "Aucun utilisateur connecté"
        }
    }
}
