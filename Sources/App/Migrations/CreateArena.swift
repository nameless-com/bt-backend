import Fluent

struct CreateArena: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("arenas")
            .id()
            .field("name", .string, .required)
            .field("address", .string, .required)
            .field("city", .string, .required)
            .field("manager_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .create()
    }
    func revert(on db: Database) async throws { try await db.schema("arenas").delete() }
}
