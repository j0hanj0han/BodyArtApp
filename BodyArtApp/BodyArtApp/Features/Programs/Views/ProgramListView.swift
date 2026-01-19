import SwiftUI
import SwiftData

struct ProgramListView: View {
    @Query(
        filter: #Predicate<Program> { $0.isPublic },
        sort: \Program.createdAt,
        order: .reverse
    ) private var programs: [Program]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Programmes publics")
        }
    }

    @ViewBuilder
    private var content: some View {
        if programs.isEmpty {
            ContentUnavailableView(
                "Aucun programme",
                systemImage: "list.bullet.clipboard",
                description: Text("Aucun programme public disponible pour le moment.")
            )
        } else {
            List(programs) { program in
                NavigationLink {
                    ProgramDetailView(program: program)
                } label: {
                    ProgramRowView(program: program)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct ProgramRowView: View {
    let program: Program

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(program.name)
                .font(.headline)

            if let description = program.programDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                Label("\(program.exercises.count) exos", systemImage: "figure.run")
                Label(program.formattedDuration, systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

struct ProgramDetailView: View {
    @Bindable var program: Program

    var body: some View {
        List {
            Section("Description") {
                Text(program.programDescription ?? "Aucune description")
                    .foregroundStyle(program.programDescription == nil ? .secondary : .primary)
            }

            Section("Exercices") {
                ForEach(program.sortedExercises) { exercise in
                    ExerciseRowView(exercise: exercise)
                }
            }

            Section("Informations") {
                LabeledContent("Durée totale", value: program.formattedDuration)
                LabeledContent("Nombre d'exercices", value: "\(program.exercises.count)")
            }

            Section {
                NavigationLink {
                    ExecuteProgramView(program: program)
                } label: {
                    Label("Démarrer l'entraînement", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(program.exercises.isEmpty)
        }
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ExerciseRowView: View {
    let exercise: ExerciseSet

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.headline)

            HStack(spacing: 16) {
                Label("\(exercise.durationSeconds)s", systemImage: "timer")
                Label("\(exercise.pauseSeconds)s pause", systemImage: "pause.circle")
                Label("\(exercise.laps)x", systemImage: "repeat")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let notes = exercise.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        ProgramListView()
    }
}
