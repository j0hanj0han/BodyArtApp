import Foundation
import SwiftData

enum WorkoutPhase {
    case idle
    case countdown
    case working
    case resting
    case finished
}

@Observable
@MainActor
final class WorkoutSession {
    let program: Program
    var currentExerciseIndex: Int
    var currentTour: Int
    var remainingSeconds: Int
    var phase: WorkoutPhase
    var isRunning: Bool
    var countdownSeconds: Int = 3

    init(program: Program) {
        self.program = program
        self.currentExerciseIndex = 0
        self.currentTour = 1
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
        if phase == .countdown { return 0.0 }
        guard let exercise = currentExercise else { return 1.0 }
        let totalSeconds = phase == .resting ? exercise.pauseSeconds : exercise.durationSeconds
        guard totalSeconds > 0 else { return 1.0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    var formattedTime: String {
        if phase == .countdown {
            return "\(countdownSeconds)"
        }
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var nextExercise: ExerciseSet? {
        let exercises = program.sortedExercises
        let nextIndex = currentExerciseIndex + 1
        if nextIndex < exercises.count {
            return exercises[nextIndex]
        }
        // Dernier exercice du tour mais il reste des tours : afficher le 1er exercice
        if currentTour < program.laps {
            return exercises.first
        }
        return nil
    }

    var isCompleted: Bool {
        phase == .finished
    }
}
