import Fluent
import BTShared

struct CreateUser: AsyncMigration {
    func prepare(on db: Database) async throws {
        let role = try await db.enum("user_role")
            .case(UserRole.player.rawValue).case(UserRole.manager.rawValue).create()
        try await db.schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("role", role, .required)
            .field("created_at", .datetime)
            .unique(on: "email")
            .create()
    }
    func revert(on db: Database) async throws {
        try await db.schema("users").delete()
        try await db.enum("user_role").delete()
    }
}
