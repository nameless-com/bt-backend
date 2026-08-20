import Vapor
import Fluent
import BTShared

struct ArenaController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let arenas = routes.grouped("arenas")
        arenas.get(use: list)             // jogador: todas; gestor: só as suas
        arenas.post(use: create)          // gestor
        arenas.group(":arenaID") { a in
            a.get(use: show)
            a.get("courts", use: courts)
        }
    }

    func list(req: Request) async throws -> [ArenaDTO] {
        let payload = try req.payload()
        var q = Arena.query(on: req.db)
        if payload.role == .manager, let id = payload.userID { q = q.filter(\.$manager.$id == id) }
        return try await q.sort(\.$name).all().map(\.dto)
    }

    func create(req: Request) async throws -> ArenaDTO {
        try req.requireRole(.manager)
        let body = try req.content.decode(CreateArenaRequest.self)
        let arena = Arena(name: body.name, address: body.address, city: body.city, managerID: try req.payload().userID!)
        try await arena.save(on: req.db)
        return arena.dto
    }

    func show(req: Request) async throws -> ArenaDTO {
        try await find(req).dto
    }

    func courts(req: Request) async throws -> [CourtDTO] {
        let arena = try await find(req)
        return try await arena.$courts.query(on: req.db).filter(\.$isActive == true).sort(\.$name).all().map(\.dto)
    }

    private func find(_ req: Request) async throws -> Arena {
        guard let arena = try await Arena.find(req.parameters.get("arenaID"), on: req.db) else { throw Abort(.notFound) }
        return arena
    }
}
