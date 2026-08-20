import Fluent
import Vapor
import BTShared

final class Arena: Model, @unchecked Sendable {
    static let schema = "arenas"

    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "address") var address: String
    @Field(key: "city") var city: String
    @Parent(key: "manager_id") var manager: User
    @Children(for: \.$arena) var courts: [Court]

    init() {}
    init(id: UUID? = nil, name: String, address: String, city: String, managerID: UUID) {
        self.id = id; self.name = name; self.address = address; self.city = city
        self.$manager.id = managerID
    }

    var dto: ArenaDTO { ArenaDTO(id: id!, name: name, address: address, city: city, managerID: $manager.id) }
}
