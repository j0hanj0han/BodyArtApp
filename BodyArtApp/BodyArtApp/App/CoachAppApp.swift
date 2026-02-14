import SwiftUI
import SwiftData
import FirebaseCore
import FacebookCore
import GoogleSignIn

@main
struct CoachAppApp: App {
    @State private var authService: AuthService
    let modelContainer: ModelContainer

    init() {
        // Firebase DOIT être configuré AVANT de créer AuthService
        FirebaseApp.configure()

        // Initialiser le SDK Facebook (lit FacebookAppID depuis Info.plist)
        ApplicationDelegate.shared.initializeSDK()

        _authService = State(initialValue: AuthService())

        do {
            modelContainer = try ModelContainer(for: Program.self, User.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .task {
                    Program.seedIfNeeded(modelContext: modelContainer.mainContext)
                }
                .onOpenURL { url in
                    // Handle Facebook callback
                    ApplicationDelegate.shared.application(
                        UIApplication.shared,
                        open: url,
                        sourceApplication: nil,
                        annotation: UIApplication.OpenURLOptionsKey.annotation
                    )
                    // Handle Google callback
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(modelContainer)
    }
}
