import SwiftData

extension ModelContainer {
    /// Creates a sample model container for use in previews.
    /// The container is in-memory only and pre-populated with sample data.
    static var sample: () throws -> ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Program.self, configurations: config)
        Task { @MainActor in
            Program.insertSampleData(modelContext: container.mainContext)
        }
        return container
    }
}
