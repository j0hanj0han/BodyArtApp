import SwiftUI
import SwiftData

struct ExecuteProgramView: View {
    @State private var viewModel: ExecuteProgramViewModel
    @Environment(\.dismiss) private var dismiss

    init(program: Program) {
        _viewModel = State(initialValue: ExecuteProgramViewModel(program: program))
    }

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            Spacer()
            timerSection
            Spacer()
            controlsSection
            settingsSection
        }
        .padding()
        .navigationTitle(viewModel.session.program.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Terminer") {
                    viewModel.stop()
                    dismiss()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            if let exercise = viewModel.session.currentExercise {
                Text(exercise.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text("Exercice \(viewModel.session.currentExerciseIndex + 1)/\(viewModel.session.totalExercises)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Tour \(viewModel.session.currentLap)/\(exercise.laps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if viewModel.session.isCompleted {
                Text("Terminé !")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
        }
    }

    // MARK: - Timer

    private var timerSection: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .foregroundStyle(.quaternary)

            Circle()
                .trim(from: 0, to: viewModel.session.progress)
                .stroke(
                    phaseColor,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: viewModel.session.progress)

            VStack(spacing: 8) {
                Text(viewModel.session.formattedTime)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))

                Text(phaseLabel)
                    .font(.headline)
                    .foregroundStyle(phaseColor)
            }
        }
        .frame(width: 280, height: 280)
    }

    private var phaseColor: Color {
        switch viewModel.session.phase {
        case .idle: return .gray
        case .working: return .green
        case .resting: return .orange
        case .finished: return .blue
        }
    }

    private var phaseLabel: String {
        switch viewModel.session.phase {
        case .idle: return "Prêt"
        case .working: return "Travail"
        case .resting: return "Repos"
        case .finished: return "Terminé"
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: 32) {
            Button {
                viewModel.stop()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(.red.opacity(0.2))
                    .foregroundStyle(.red)
                    .clipShape(Circle())
            }

            Button {
                viewModel.togglePlayPause()
            } label: {
                Image(systemName: viewModel.session.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .background(viewModel.session.isCompleted ? .gray.opacity(0.2) : .green.opacity(0.2))
                    .foregroundStyle(viewModel.session.isCompleted ? .gray : .green)
                    .clipShape(Circle())
            }
            .disabled(viewModel.session.isCompleted)

            Button {
                viewModel.nextExercise()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(.blue.opacity(0.2))
                    .foregroundStyle(.blue)
                    .clipShape(Circle())
            }
            .disabled(viewModel.session.isCompleted)
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        HStack(spacing: 24) {
            Toggle(isOn: $viewModel.hapticsEnabled) {
                Label("Vibrations", systemImage: "iphone.radiowaves.left.and.right")
            }
            .toggleStyle(.button)
            .tint(viewModel.hapticsEnabled ? .blue : .gray)

            Toggle(isOn: $viewModel.soundEnabled) {
                Label("Sons", systemImage: "speaker.wave.2")
            }
            .toggleStyle(.button)
            .tint(viewModel.soundEnabled ? .blue : .gray)
        }
        .font(.caption)
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        NavigationStack {
            ExecuteProgramView(program: .hiitDebutant)
        }
    }
}
