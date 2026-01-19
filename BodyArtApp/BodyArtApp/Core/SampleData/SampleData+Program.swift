import Foundation
import SwiftData

extension Program {
    // MARK: - Sample Programs

    static let hiitDebutant = Program(
        name: "HIIT Débutant",
        programDescription: "Programme d'introduction au HIIT pour débutants",
        isPublic: true
    )

    static let cardioIntense = Program(
        name: "Cardio Intense",
        programDescription: "Séance cardio haute intensité",
        isPublic: true
    )

    static let renforcementCore = Program(
        name: "Renforcement Core",
        programDescription: "Travail des abdominaux et du gainage",
        isPublic: true
    )

    static let fullBodyExpress = Program(
        name: "Full Body Express",
        programDescription: "Entraînement complet en 15 minutes",
        isPublic: true
    )

    static let stretchingRecuperation = Program(
        name: "Stretching Récupération",
        programDescription: "Séance d'étirements pour la récupération",
        isPublic: true
    )

    // MARK: - Seed Data

    @MainActor
    static func insertSampleData(modelContext: ModelContext) {
        // Insert programs
        modelContext.insert(hiitDebutant)
        modelContext.insert(cardioIntense)
        modelContext.insert(renforcementCore)
        modelContext.insert(fullBodyExpress)
        modelContext.insert(stretchingRecuperation)

        // Add exercises to HIIT Débutant
        hiitDebutant.exercises = [
            ExerciseSet(name: "Jumping Jacks", durationSeconds: 30, pauseSeconds: 15, laps: 3, order: 0),
            ExerciseSet(name: "Squats", durationSeconds: 30, pauseSeconds: 15, laps: 3, order: 1),
            ExerciseSet(name: "Pompes", durationSeconds: 30, pauseSeconds: 15, laps: 3, order: 2)
        ]

        // Add exercises to Cardio Intense
        cardioIntense.exercises = [
            ExerciseSet(name: "Burpees", durationSeconds: 45, pauseSeconds: 20, laps: 4, order: 0),
            ExerciseSet(name: "Mountain Climbers", durationSeconds: 45, pauseSeconds: 20, laps: 4, order: 1),
            ExerciseSet(name: "High Knees", durationSeconds: 45, pauseSeconds: 20, laps: 4, order: 2)
        ]

        // Add exercises to Renforcement Core
        renforcementCore.exercises = [
            ExerciseSet(name: "Planche", durationSeconds: 45, pauseSeconds: 15, laps: 3, order: 0),
            ExerciseSet(name: "Crunchs", durationSeconds: 30, pauseSeconds: 15, laps: 3, order: 1),
            ExerciseSet(name: "Russian Twist", durationSeconds: 30, pauseSeconds: 15, laps: 3, order: 2)
        ]

        // Add exercises to Full Body Express
        fullBodyExpress.exercises = [
            ExerciseSet(name: "Squats sautés", durationSeconds: 40, pauseSeconds: 20, laps: 2, order: 0),
            ExerciseSet(name: "Pompes", durationSeconds: 40, pauseSeconds: 20, laps: 2, order: 1),
            ExerciseSet(name: "Fentes alternées", durationSeconds: 40, pauseSeconds: 20, laps: 2, order: 2)
        ]

        // Add exercises to Stretching Récupération
        stretchingRecuperation.exercises = [
            ExerciseSet(name: "Étirement quadriceps", durationSeconds: 60, pauseSeconds: 10, laps: 2, order: 0),
            ExerciseSet(name: "Étirement ischio-jambiers", durationSeconds: 60, pauseSeconds: 10, laps: 2, order: 1),
            ExerciseSet(name: "Étirement dorsaux", durationSeconds: 60, pauseSeconds: 10, laps: 2, order: 2)
        ]
    }

    @MainActor
    static func seedIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Program>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0

        guard count == 0 else { return }

        insertSampleData(modelContext: modelContext)
    }
}
