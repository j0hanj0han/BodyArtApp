import SwiftUI
import SwiftData
import FirebaseCore
import FacebookCore
import GoogleSignIn

@main
struct BodyArt974App: App {
    @State private var authService: AuthService
    private let modelContainerResult: Result<ModelContainer, Error>

    init() {
        // Firebase DOIT être configuré AVANT de créer AuthService
        FirebaseApp.configure()

        // Désactiver le tracking publicitaire Facebook (pas de pub dans cette app)
        Settings.shared.isAutoLogAppEventsEnabled = false
        Settings.shared.isAdvertiserIDCollectionEnabled = false

        // Initialiser le SDK Facebook (lit FacebookAppID depuis Info.plist)
        ApplicationDelegate.shared.initializeSDK()

        _authService = State(initialValue: AuthService())

        do {
            let container = try ModelContainer(for: Program.self, User.self)
            modelContainerResult = .success(container)
        } catch {
            modelContainerResult = .failure(error)
        }
    }

    var body: some Scene {
        WindowGroup {
            switch modelContainerResult {
            case .success(let container):
                RootView()
                    .environment(authService)
                    .task {
                        Program.seedIfNeeded(modelContext: container.mainContext)
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
                    .modelContainer(container)
            case .failure(let error):
                ContentUnavailableView(
                    "Erreur de démarrage",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            }
        }
    }
}
