import SwiftUI
import SwiftData

@main
struct CoachAppApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Program.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await MainActor.run {
                        Program.seedIfNeeded(modelContext: modelContainer.mainContext)
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
