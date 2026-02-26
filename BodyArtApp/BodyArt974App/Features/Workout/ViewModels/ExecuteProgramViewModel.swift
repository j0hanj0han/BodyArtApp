import Foundation
import UIKit

@Observable
@MainActor
final class ExecuteProgramViewModel {
    private(set) var session: WorkoutSession
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true

    private var timerTask: Task<Void, Never>?

    init(program: Program) {
        self.session = WorkoutSession(program: program)
    }

    // MARK: - Controls

    func start() {
        guard !session.program.sortedExercises.isEmpty else { return }

        if session.phase == .idle {
            session.phase = .countdown
            session.countdownSeconds = 3
        }
        session.isRunning = true
        startTimer()
        triggerHaptic(.medium)
    }

    func pause() {
        session.isRunning = false
        timerTask?.cancel()
        timerTask = nil
        triggerHaptic(.light)
    }

    func togglePlayPause() {
        if session.isRunning {
            pause()
        } else {
            start()
        }
    }

    func nextExercise() {
        moveToNextExercise()
        triggerHaptic(.medium)
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        session = WorkoutSession(program: session.program)
        triggerHaptic(.heavy)
    }

    func reset() {
        stop()
    }

    // MARK: - Timer Logic

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self?.tick()
            }
        }
    }

    private func tick() {
        guard session.isRunning else { return }

        if session.phase == .countdown {
            if session.countdownSeconds > 1 {
                session.countdownSeconds -= 1
                triggerHaptic(.light)
            } else {
                session.phase = .working
                session.remainingSeconds = session.currentExercise?.durationSeconds ?? 0
                triggerHaptic(.medium)
            }
            return
        }

        if session.remainingSeconds > 0 {
            session.remainingSeconds -= 1

            if session.remainingSeconds <= 3 && session.remainingSeconds > 0 {
                triggerHaptic(.light)
            }
        } else {
            handlePhaseTransition()
        }
    }

    private func handlePhaseTransition() {
        guard let exercise = session.currentExercise else {
            finishWorkout()
            return
        }

        switch session.phase {
        case .working:
            if exercise.pauseSeconds > 0 {
                session.phase = .resting
                session.remainingSeconds = exercise.pauseSeconds
                triggerHaptic(.success)
            } else {
                moveToNextExercise()
            }

        case .resting:
            moveToNextExercise()

        case .countdown, .idle, .finished:
            break
        }
    }

    private func moveToNextExercise() {
        let nextIndex = session.currentExerciseIndex + 1
        let exercises = session.program.sortedExercises

        if nextIndex < exercises.count {
            session.currentExerciseIndex = nextIndex
            session.phase = .working
            session.remainingSeconds = exercises[nextIndex].durationSeconds
            triggerHaptic(.success)
        } else {
            let nextTour = session.currentTour + 1
            if nextTour <= session.program.laps {
                session.currentTour = nextTour
                session.currentExerciseIndex = 0
                session.phase = .working
                session.remainingSeconds = exercises[0].durationSeconds
                triggerHaptic(.success)
            } else {
                finishWorkout()
            }
        }
    }

    private func finishWorkout() {
        timerTask?.cancel()
        timerTask = nil
        session.phase = .finished
        session.isRunning = false
        triggerHaptic(.success)
    }

    // MARK: - Haptics

    private func triggerHaptic(_ style: HapticStyle) {
        guard hapticsEnabled else { return }

        #if targetEnvironment(simulator)
        // Haptics not available on simulator
        #else
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        #endif
    }
}

private enum HapticStyle {
    case light, medium, heavy, success
}
