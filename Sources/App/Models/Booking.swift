import Fluent
import Vapor
import BTShared

final class Booking: Model, @unchecked Sendable {
    static let schema = "bookings"

    @ID(key: .id) var id: UUID?
    @Parent(key: "court_id") var court: Court
    @Parent(key: "player_id") var player: User
    @Field(key: "starts_at") var startsAt: Date
    @Field(key: "ends_at") var endsAt: Date
    @Enum(key: "status") var status: BookingStatus
    @Field(key: "total_cents") var totalCents: Int
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}
    init(id: UUID? = nil, courtID: UUID, playerID: UUID, startsAt: Date, endsAt: Date, status: BookingStatus, totalCents: Int) {
        self.id = id; self.$court.id = courtID; self.$player.id = playerID
        self.startsAt = startsAt; self.endsAt = endsAt; self.status = status; self.totalCents = totalCents
    }

    var dto: BookingDTO {
        BookingDTO(id: id!, courtID: $court.id, playerID: $player.id, startsAt: startsAt, endsAt: endsAt, status: status, totalCents: totalCents)
    }
}
