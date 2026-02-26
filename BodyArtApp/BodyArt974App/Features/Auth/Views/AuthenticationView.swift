import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                AuthView()
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(AuthService())
}
