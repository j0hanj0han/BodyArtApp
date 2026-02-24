import SwiftUI

struct AuthenticationView: View {
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                if showSignUp {
                    SignUpView(showSignUp: $showSignUp)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                } else {
                    LoginView(showSignUp: $showSignUp)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showSignUp)
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(AuthService())
}
