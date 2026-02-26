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

                if let next = viewModel.session.nextExercise,
                   viewModel.session.phase != .countdown,
                   !viewModel.session.isCompleted {
                    NextExerciseView(exercise: next)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                WorkoutSettingsView(
                    hapticsEnabled: $viewModel.hapticsEnabled,
                    soundEnabled: $viewModel.soundEnabled
                )
            }
            .padding()
            .animation(.easeInOut(duration: 0.3), value: viewModel.session.currentExerciseIndex)
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
                        "Tour \(session.currentTour)/\(session.program.laps)",
                        systemImage: "repeat"
                    )
                    Label(
                        "Exercice \(session.currentExerciseIndex + 1)/\(session.totalExercises)",
                        systemImage: "list.number"
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
        case .countdown: return .white
        case .working: return .green
        case .resting: return .orange
        case .finished: return .blue
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .idle: return "Prêt"
        case .countdown: return ""
        case .working: return "Travail"
        case .resting: return "Repos"
        case .finished: return "Terminé"
        }
    }

    var body: some View {
        if phase == .countdown {
            Text(formattedTime)
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .foregroundStyle(.white)
                .animation(.easeInOut(duration: 0.3), value: formattedTime)
                .frame(width: 280, height: 280)
        } else {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .foregroundStyle(.white.opacity(0.15))

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
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .frame(width: 280, height: 280)
        }
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
                .background(.ultraThinMaterial, in: Circle())
                .foregroundStyle(tint)
                .shadow(color: tint.opacity(0.25), radius: 8, y: 4)
        }
    }
}

// MARK: - Next Exercise

struct NextExerciseView: View {
    let exercise: ExerciseSet

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            VStack(alignment: .leading, spacing: 2) {
                Text("Suivant")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(exercise.name)
                    .font(.subheadline).fontWeight(.semibold)
            }
            Spacer()
            HStack(spacing: 8) {
                Label("\(exercise.durationSeconds)s", systemImage: "timer")
                Label("\(exercise.laps)x", systemImage: "repeat")
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
            .symbolRenderingMode(.hierarchical)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
    }
}

#Preview {
    ModelContainerPreview(ModelContainer.sample) {
        NavigationStack {
            ExecuteProgramView(program: .hiitDebutant)
        }
    }
}
