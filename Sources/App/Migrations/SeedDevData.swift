import Fluent
import Vapor
import BTShared

/// Dados de exemplo para os dois apps terem algo para mostrar em dev.
/// Logins: gestor@bt.dev / 123456  e  jogador@bt.dev / 123456
struct SeedDevData: AsyncMigration {
    func prepare(on db: Database) async throws {
        let hash = try Bcrypt.hash("123456")
        let manager = User(name: "Gestor Demo", email: "gestor@bt.dev", passwordHash: hash, role: .manager)
        let player = User(name: "Jogador Demo", email: "jogador@bt.dev", passwordHash: hash, role: .player)
        try await manager.save(on: db)
        try await player.save(on: db)

        let arena = Arena(name: "Arena Praia Central", address: "Av. Beira-Mar, 100", city: "Fortaleza", managerID: manager.id!)
        try await arena.save(on: db)

        for (i, price) in [8000, 8000, 10000].enumerated() {
            try await Court(arenaID: arena.id!, name: "Quadra \(i + 1)", pricePerHourCents: price).save(on: db)
        }
    }
    func revert(on db: Database) async throws {
        try await User.query(on: db).filter(\.$email ~~ ["gestor@bt.dev", "jogador@bt.dev"]).delete()
    }
}
