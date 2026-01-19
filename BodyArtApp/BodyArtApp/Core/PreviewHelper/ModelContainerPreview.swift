import SwiftUI
import SwiftData

/// A view wrapper for previews that creates a model container before showing content.
/// Use this in #Preview blocks to ensure SwiftData is properly configured.
struct ModelContainerPreview<Content: View>: View {
    var content: () -> Content
    let container: ModelContainer

    /// Creates an instance with a custom model container closure.
    ///
    /// Example:
    /// ```
    /// #Preview {
    ///     ModelContainerPreview {
    ///         ProgramListView()
    ///     } modelContainer: {
    ///         let config = ModelConfiguration(isStoredInMemoryOnly: true)
    ///         let container = try ModelContainer(for: Program.self, configurations: config)
    ///         Program.insertSampleData(modelContext: container.mainContext)
    ///         return container
    ///     }
    /// }
    /// ```
    init(
        @ViewBuilder content: @escaping () -> Content,
        modelContainer: @escaping () throws -> ModelContainer
    ) {
        self.content = content
        do {
            self.container = try MainActor.assumeIsolated(modelContainer)
        } catch {
            fatalError("Failed to create the model container: \(error.localizedDescription)")
        }
    }

    /// Creates an instance with a pre-configured model container closure.
    ///
    /// Example:
    /// ```
    /// #Preview {
    ///     ModelContainerPreview(ModelContainer.sample) {
    ///         ProgramListView()
    ///     }
    /// }
    /// ```
    init(
        _ modelContainer: @escaping () throws -> ModelContainer,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(content: content, modelContainer: modelContainer)
    }

    var body: some View {
        content()
            .modelContainer(container)
    }
}
