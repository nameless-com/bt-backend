import Fluent

struct CreateCourt: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("courts")
            .id()
            .field("arena_id", .uuid, .required, .references("arenas", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .field("price_per_hour_cents", .int, .required)
            .field("is_active", .bool, .required, .sql(.default(true)))
            .create()
    }
    func revert(on db: Database) async throws { try await db.schema("courts").delete() }
}
