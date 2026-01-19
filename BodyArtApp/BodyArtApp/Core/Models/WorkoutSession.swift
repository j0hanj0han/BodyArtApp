import Foundation
import SwiftData

enum WorkoutPhase {
    case idle
    case working
    case resting
    case finished
}

@Observable
@MainActor
final class WorkoutSession {
    let program: Program
    var currentExerciseIndex: Int
    var currentLap: Int
    var remainingSeconds: Int
    var phase: WorkoutPhase
    var isRunning: Bool

    init(program: Program) {
        self.program = program
        self.currentExerciseIndex = 0
        self.currentLap = 1
        self.remainingSeconds = program.sortedExercises.first?.durationSeconds ?? 0
        self.phase = .idle
        self.isRunning = false
    }

    var currentExercise: ExerciseSet? {
        let exercises = program.sortedExercises
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }

    var totalExercises: Int {
        program.exercises.count
    }

    var progress: Double {
        guard let exercise = currentExercise else { return 1.0 }
        let totalSeconds = phase == .resting ? exercise.pauseSeconds : exercise.durationSeconds
        guard totalSeconds > 0 else { return 1.0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var isCompleted: Bool {
        phase == .finished
    }
}
