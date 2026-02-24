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
                } else {
                    LoginView(showSignUp: $showSignUp)
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(AuthService())
}
