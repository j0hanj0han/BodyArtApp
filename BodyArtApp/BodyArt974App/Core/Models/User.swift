import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var uid: String
    var email: String
    var displayName: String?
    var role: UserRole
    var createdAt: Date
    var photoURL: String?

    init(
        uid: String,
        email: String,
        displayName: String? = nil,
        role: UserRole = .member,
        createdAt: Date = Date(),
        photoURL: String? = nil
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.role = role
        self.createdAt = createdAt
        self.photoURL = photoURL
    }
}

enum UserRole: String, Codable {
    case coach
    case member
}
