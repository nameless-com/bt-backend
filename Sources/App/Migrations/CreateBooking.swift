import Fluent
import BTShared

struct CreateBooking: AsyncMigration {
    func prepare(on db: Database) async throws {
        let status = try await db.enum("booking_status")
            .case(BookingStatus.pending.rawValue)
            .case(BookingStatus.confirmed.rawValue)
            .case(BookingStatus.cancelled.rawValue)
            .create()
        try await db.schema("bookings")
            .id()
            .field("court_id", .uuid, .required, .references("courts", "id", onDelete: .cascade))
            .field("player_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("starts_at", .datetime, .required)
            .field("ends_at", .datetime, .required)
            .field("status", status, .required)
            .field("total_cents", .int, .required)
            .field("created_at", .datetime)
            .create()
    }
    func revert(on db: Database) async throws {
        try await db.schema("bookings").delete()
        try await db.enum("booking_status").delete()
    }
}
