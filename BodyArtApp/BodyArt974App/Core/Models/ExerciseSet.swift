import Foundation
import SwiftData

@Model
final class ExerciseSet {
    var name: String
    var durationSeconds: Int
    var pauseSeconds: Int
    var laps: Int
    var notes: String?
    var order: Int = 0
    var program: Program?

    init(
        name: String,
        durationSeconds: Int,
        pauseSeconds: Int,
        notes: String? = nil,
        order: Int = 0
    ) {
        self.name = name
        self.durationSeconds = durationSeconds
        self.pauseSeconds = pauseSeconds
        self.laps = 1
        self.notes = notes
        self.order = order
    }
}
