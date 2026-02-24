import SwiftUI
import SwiftData

struct CreateProgramView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) private var authService

    @State private var name: String = ""
    @State private var programDescription: String = ""
    @State private var exercises: [ExerciseSet] = []
    @State private var isPublic: Bool = false
    @State private var showingAddExercise = false
    @State private var showingSaveSuccess = false
    @State private var savedProgramName: String = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !exercises.isEmpty
    }

    private var totalDuration: Int {
        exercises.reduce(0) { $0 + ($1.durationSeconds + $1.pauseSeconds) * $1.laps }
    }

    private var formattedTotalDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return minutes > 0 ? "\(minutes) min \(seconds) s" : "\(seconds) s"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background").resizable().scaledToFill().ignoresSafeArea()

                Form {
                    programInfoSection
                    exercisesSection
                    summarySection
                    saveSection
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Nouveau programme")
                .navigationBarTitleDisplayMode(.large)
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView { exercise in
                    exercise.order = exercises.count
                    exercises.append(exercise)
                }
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(28)
            }
            .alert("Programme créé", isPresented: $showingSaveSuccess) {
                Button("OK") { reset() }
            } message: {
                Text("Le programme \"\(savedProgramName)\" a été créé avec succès.")
            }
        }
    }

    // MARK: - Sections

    private var programInfoSection: some View {
        Section("Informations") {
            TextField("Nom du programme", text: $name)
            TextField("Description (optionnel)", text: $programDescription, axis: .vertical)
                .lineLimit(3...6)
            Toggle("Programme public", isOn: $isPublic)
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var exercisesSection: some View {
        Section {
            if exercises.isEmpty {
                ContentUnavailableView {
                    Label("Aucun exercice", systemImage: "figure.run")
                } description: {
                    Text("Ajoutez des exercices à votre programme")
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(exercises) { exercise in
                    ExerciseEditRowView(exercise: exercise)
                }
                .onDelete(perform: removeExercise)
                .onMove(perform: moveExercise)
            }

            Button {
                showingAddExercise = true
            } label: {
                Label("Ajouter un exercice", systemImage: "plus.circle.fill")
            }
        } header: {
            HStack {
                Text("Exercices")
                Spacer()
                if !exercises.isEmpty {
                    Text("\(exercises.count)").foregroundStyle(.secondary)
                }
            }
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var summarySection: some View {
        Section("Résumé") {
            LabeledContent("Nombre d'exercices", value: "\(exercises.count)")
            LabeledContent("Durée totale", value: formattedTotalDuration)
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    private var saveSection: some View {
        Section {
            Button {
                saveProgram()
            } label: {
                Text("Enregistrer le programme")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!isValid)
        }
        .listRowBackground(Rectangle().fill(.regularMaterial))
    }

    // MARK: - Actions

    private func removeExercise(at indexSet: IndexSet) {
        exercises.remove(atOffsets: indexSet)
        updateExerciseOrder()
    }

    private func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        updateExerciseOrder()
    }

    private func updateExerciseOrder() {
        for (index, exercise) in exercises.enumerated() {
            exercise.order = index
        }
    }

    private func saveProgram() {
        let program = Program(
            name: name.trimmingCharacters(in: .whitespaces),
            programDescription: programDescription.isEmpty
                ? nil : programDescription.trimmingCharacters(in: .whitespaces),
            exercises: exercises,
            isPublic: isPublic,
            createdByUID: authService.currentUserUID
        )
        modelContext.insert(program)
        savedProgramName = program.name
        showingSaveSuccess = true
    }

    private func reset() {
        name = ""
        programDescription = ""
        exercises = []
        isPublic = false
    }
}

// MARK: - Exercise Edit Row

struct ExerciseEditRowView: View {
    let exercise: ExerciseSet

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name).font(.headline)
            HStack(spacing: 12) {
                Label("\(exercise.durationSeconds)s", systemImage: "timer")
                Label("\(exercise.pauseSeconds)s", systemImage: "pause.circle")
                Label("\(exercise.laps)x", systemImage: "repeat")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .symbolRenderingMode(.hierarchical)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        CreateProgramView()
    }
}
