import SwiftUI
import SwiftData

// MARK: - Program List

struct ProgramListView: View {
    @Query(
        filter: #Predicate<Program> { $0.isPublic },
        sort: \Program.createdAt,
        order: .reverse
    ) private var programs: [Program]

    var body: some View {
        NavigationStack {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            Image("Background").resizable().scaledToFill().ignoresSafeArea()

            List {
                if programs.isEmpty {
                    // Empty state rendered inside the List so the scroll
                    // container — and therefore the large title — always
                    // has a stable anchor that iOS 26 can track.
                } else {
                    ForEach(programs) { program in
                        NavigationLink {
                            ProgramDetailView(program: program)
                        } label: {
                            ProgramRowView(program: program)
                        }
                        .listRowBackground(Rectangle().fill(.regularMaterial))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Programmes publics")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if programs.isEmpty {
                    ContentUnavailableView(
                        "Aucun programme",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Aucun programme public disponible pour le moment.")
                    )
                }
            }
        }
    }
}

// MARK: - Program Row

struct ProgramRowView: View {
    let program: Program

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
            .symbolRenderingMode(.hierarchical)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Program Detail

struct ProgramDetailView: View {
    @Bindable var program: Program

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("Background").resizable().scaledToFill().ignoresSafeArea()

            List {
                descriptionSection
                exercisesSection
                infoSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle(program.name)
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom) {
                startWorkoutBar
            }
        }
    }

    private var descriptionSection: some View {
        Section("Description") {
            Text(program.programDescription ?? "Aucune description")
                .foregroundStyle(program.programDescription == nil ? .secondary : .primary)
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var exercisesSection: some View {
        Section("Exercices") {
            ForEach(program.sortedExercises) { exercise in
                ExerciseRowView(exercise: exercise)
            }
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var infoSection: some View {
        Section("Informations") {
            LabeledContent("Durée totale", value: program.formattedDuration)
            LabeledContent("Nombre d'exercices", value: "\(program.exercises.count)")
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var startWorkoutBar: some View {
        NavigationLink {
            ExecuteProgramView(program: program)
        } label: {
            Label("Démarrer l'entraînement", systemImage: "play.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .disabled(program.exercises.isEmpty)
    }
}

// MARK: - Exercise Row

struct ExerciseRowView: View {
    let exercise: ExerciseSet

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(exercise.name)
                .font(.headline)

            HStack(spacing: 16) {
                Label("\(exercise.durationSeconds)s", systemImage: "timer")
                Label("\(exercise.pauseSeconds)s pause", systemImage: "pause.circle")
                Label("\(exercise.laps)x", systemImage: "repeat")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .symbolRenderingMode(.hierarchical)

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
