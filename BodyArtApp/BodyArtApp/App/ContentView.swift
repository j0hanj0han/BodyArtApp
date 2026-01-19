import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            ProgramListView()
                .tabItem {
                    Label("Programmes", systemImage: "list.bullet.clipboard")
                }

            CreateProgramView()
                .tabItem {
                    Label("Créer", systemImage: "plus.circle")
                }

            Text("Profil")
                .tabItem {
                    Label("Profil", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        ContentView()
    }
}
