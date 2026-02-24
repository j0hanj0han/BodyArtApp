import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            TabView {
                ProgramListView()
                    .tabItem {
                        Label("Programmes", systemImage: "list.bullet.clipboard")
                    }

                CreateProgramView()
                    .tabItem {
                        Label("Créer", systemImage: "plus.circle")
                    }

                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.circle")
                    }
            }
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        ContentView()
    }
}
