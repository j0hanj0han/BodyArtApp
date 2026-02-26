import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var durationSeconds: Int = 30
    @State private var pauseSeconds: Int = 15
    @State private var notes: String = ""

    let onSave: (ExerciseSet) -> Void

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && durationSeconds > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                timingSection
                notesSection
                ExercisePreviewSection(
                    name: name,
                    durationSeconds: durationSeconds,
                    pauseSeconds: pauseSeconds
                )
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Nouvel exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { saveExercise() }
                        .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        Section("Nom de l'exercice") {
            TextField("Ex: Pompes, Squats, Planche...", text: $name)
            ExerciseSuggestionsView(selectedName: $name)
        }
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }

    private var timingSection: some View {
        Section("Durée") {
            Stepper(value: $durationSeconds, in: 5...300, step: 5) {
                LabeledContent("Travail", value: "\(durationSeconds) sec")
            }
            Stepper(value: $pauseSeconds, in: 0...120, step: 5) {
                LabeledContent("Repos", value: "\(pauseSeconds) sec")
            }
        }
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }

    private var notesSection: some View {
        Section("Notes (optionnel)") {
            TextField("Conseils, variantes...", text: $notes, axis: .vertical)
                .lineLimit(2...4)
        }
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }

    private func saveExercise() {
        let exercise = ExerciseSet(
            name: name.trimmingCharacters(in: .whitespaces),
            durationSeconds: durationSeconds,
            pauseSeconds: pauseSeconds,
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)
        )
        onSave(exercise)
        dismiss()
    }
}

// MARK: - Exercise Suggestions

private struct ExerciseSuggestionsView: View {
    @Binding var selectedName: String

    private static let suggestions = [
        "Pompes", "Squats", "Burpees", "Planche",
        "Crunchs", "Fentes", "Mountain Climbers", "Jumping Jacks"
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Self.suggestions, id: \.self) { suggestion in
                    Button(suggestion) { selectedName = suggestion }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

// MARK: - Exercise Preview

private struct ExercisePreviewSection: View {
    let name: String
    let durationSeconds: Int
    let pauseSeconds: Int

    private var totalTime: Int { durationSeconds + pauseSeconds }

    var body: some View {
        Section("Aperçu") {
            VStack(alignment: .leading, spacing: 8) {
                Text(name.isEmpty ? "Nom de l'exercice" : name)
                    .font(.headline)
                    .foregroundStyle(name.isEmpty ? .tertiary : .primary)

                HStack(spacing: 16) {
                    Label("\(durationSeconds)s travail", systemImage: "timer")
                    Label("\(pauseSeconds)s repos", systemImage: "pause.circle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)

                Text("Durée totale: \(totalTime / 60) min \(totalTime % 60) s")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }
}

#Preview {
    AddExerciseView { exercise in
        print("Added: \(exercise.name)")
    }
}
