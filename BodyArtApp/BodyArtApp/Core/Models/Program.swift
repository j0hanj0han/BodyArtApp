import Foundation
import SwiftData

@Model
final class Program {
    var name: String
    var programDescription: String?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.program)
    var exercises: [ExerciseSet] = []
    var isPublic: Bool = false
    var createdAt: Date = Date()

    init(
        name: String,
        programDescription: String? = nil,
        exercises: [ExerciseSet] = [],
        isPublic: Bool = false,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.programDescription = programDescription
        self.exercises = exercises
        self.isPublic = isPublic
        self.createdAt = createdAt
    }
}

extension Program {
    var sortedExercises: [ExerciseSet] {
        exercises.sorted { $0.order < $1.order }
    }

    var totalDuration: Int {
        exercises.reduce(0) { total, exercise in
            total + (exercise.durationSeconds + exercise.pauseSeconds) * exercise.laps
        }
    }

    var formattedDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        if minutes > 0 {
            return "\(minutes) min \(seconds) s"
        }
        return "\(seconds) s"
    }
}
