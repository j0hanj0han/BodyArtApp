import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var uid: String
    var email: String
    var displayName: String?
    var role: UserRole
    var createdAt: Date

    init(
        uid: String,
        email: String,
        displayName: String? = nil,
        role: UserRole = .member,
        createdAt: Date = Date()
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.role = role
        self.createdAt = createdAt
    }
}

enum UserRole: String, Codable {
    case coach
    case member
}
