import SwiftUI
import SwiftData

struct ExecuteProgramView: View {
    @State private var viewModel: ExecuteProgramViewModel
    @Environment(\.dismiss) private var dismiss

    init(program: Program) {
        _viewModel = State(initialValue: ExecuteProgramViewModel(program: program))
    }

    var body: some View {
        ZStack {
            Image("Background").resizable().scaledToFill().ignoresSafeArea()

            VStack(spacing: 24) {
                WorkoutHeaderView(session: viewModel.session)
                Spacer()
                WorkoutTimerView(
                    progress: viewModel.session.progress,
                    formattedTime: viewModel.session.formattedTime,
                    phase: viewModel.session.phase
                )
                Spacer()
                WorkoutControlsView(
                    isRunning: viewModel.session.isRunning,
                    isCompleted: viewModel.session.isCompleted,
                    phase: viewModel.session.phase,
                    onStop: { viewModel.stop() },
                    onPlayPause: { viewModel.togglePlayPause() },
                    onNext: { viewModel.nextExercise() }
                )
                WorkoutSettingsView(
                    hapticsEnabled: $viewModel.hapticsEnabled,
                    soundEnabled: $viewModel.soundEnabled
                )
            }
            .padding()
        }
        .navigationTitle(viewModel.session.program.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Terminer") {
                    viewModel.stop()
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Header

struct WorkoutHeaderView: View {
    let session: WorkoutSession

    var body: some View {
        VStack(spacing: 8) {
            if let exercise = session.currentExercise {
                Text(exercise.name)
                    .font(.title2).fontWeight(.bold)
                    .multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    Label(
                        "Exercice \(session.currentExerciseIndex + 1)/\(session.totalExercises)",
                        systemImage: "list.number"
                    )
                    Label(
                        "Tour \(session.currentLap)/\(exercise.laps)",
                        systemImage: "repeat"
                    )
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            } else if session.isCompleted {
                Text("Terminé !")
                    .font(.title).fontWeight(.bold)
                    .foregroundStyle(.green)
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Timer Ring

struct WorkoutTimerView: View {
    let progress: Double
    let formattedTime: String
    let phase: WorkoutPhase

    private var phaseColor: Color {
        switch phase {
        case .idle: return .gray
        case .working: return .green
        case .resting: return .orange
        case .finished: return .blue
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .idle: return "Prêt"
        case .working: return "Travail"
        case .resting: return "Repos"
        case .finished: return "Terminé"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .foregroundStyle(.regularMaterial)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(phaseColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)

            VStack(spacing: 8) {
                Text(formattedTime)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())

                Text(phaseLabel)
                    .font(.headline)
                    .foregroundStyle(phaseColor)
            }
        }
        .frame(width: 280, height: 280)
    }
}

// MARK: - Controls

struct WorkoutControlsView: View {
    let isRunning: Bool
    let isCompleted: Bool
    let phase: WorkoutPhase
    let onStop: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 32) {
            WorkoutControlButton(
                systemImage: "stop.fill",
                tint: .red,
                size: 60,
                action: onStop
            )
            .accessibilityLabel("Arrêter")

            WorkoutControlButton(
                systemImage: isRunning ? "pause.fill" : "play.fill",
                tint: isCompleted ? .gray : .green,
                size: 80,
                action: onPlayPause
            )
            .disabled(isCompleted)
            .accessibilityLabel(isRunning ? "Pause" : "Démarrer")

            WorkoutControlButton(
                systemImage: "forward.fill",
                tint: .blue,
                size: 60,
                action: onNext
            )
            .disabled(isCompleted)
            .accessibilityLabel("Exercice suivant")
        }
    }
}

struct WorkoutControlButton: View {
    let systemImage: String
    let tint: Color
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(size == 80 ? .title : .title2)
                .frame(width: size, height: size)
                .background(.regularMaterial, in: Circle())
                .foregroundStyle(tint)
                .shadow(color: tint.opacity(0.25), radius: 8, y: 4)
        }
    }
}

// MARK: - Settings

struct WorkoutSettingsView: View {
    @Binding var hapticsEnabled: Bool
    @Binding var soundEnabled: Bool

    var body: some View {
        HStack(spacing: 16) {
            Toggle(isOn: $hapticsEnabled) {
                Label("Vibrations", systemImage: "iphone.radiowaves.left.and.right")
            }
            .toggleStyle(.button)
            .tint(hapticsEnabled ? .blue : .gray)

            Toggle(isOn: $soundEnabled) {
                Label("Sons", systemImage: "speaker.wave.2")
            }
            .toggleStyle(.button)
            .tint(soundEnabled ? .blue : .gray)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        NavigationStack {
            ExecuteProgramView(program: .hiitDebutant)
        }
    }
}
