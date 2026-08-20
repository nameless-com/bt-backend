import Fluent
import Vapor
import BTShared

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "email") var email: String
    @Field(key: "password_hash") var passwordHash: String
    @Enum(key: "role") var role: UserRole
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}
    init(id: UUID? = nil, name: String, email: String, passwordHash: String, role: UserRole) {
        self.id = id; self.name = name; self.email = email
        self.passwordHash = passwordHash; self.role = role
    }

    var dto: UserDTO { UserDTO(id: id!, name: name, email: email, role: role) }
}
