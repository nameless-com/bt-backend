import Fluent
import Vapor
import BTShared

final class Court: Model, @unchecked Sendable {
    static let schema = "courts"

    @ID(key: .id) var id: UUID?
    @Parent(key: "arena_id") var arena: Arena
    @Field(key: "name") var name: String
    @Field(key: "price_per_hour_cents") var pricePerHourCents: Int
    @Field(key: "is_active") var isActive: Bool

    init() {}
    init(id: UUID? = nil, arenaID: UUID, name: String, pricePerHourCents: Int, isActive: Bool = true) {
        self.id = id; self.$arena.id = arenaID; self.name = name
        self.pricePerHourCents = pricePerHourCents; self.isActive = isActive
    }

    var dto: CourtDTO { CourtDTO(id: id!, arenaID: $arena.id, name: name, pricePerHourCents: pricePerHourCents, isActive: isActive) }
}
