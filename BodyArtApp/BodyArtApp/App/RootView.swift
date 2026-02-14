import SwiftUI

struct RootView: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        Group {
            switch authService.authState {
            case .loading:
                ProgressView("Chargement...")
            case .authenticated:
                ContentView()
            case .unauthenticated:
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: authService.authState)
    }
}

#Preview("Loading") {
    RootView()
        .environment(AuthService())
}
