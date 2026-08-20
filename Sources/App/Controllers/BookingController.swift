import Vapor
import Fluent
import BTShared

struct BookingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bookings = routes.grouped("bookings")
        bookings.get(use: list)           // jogador: as suas; gestor: das suas arenas
        bookings.post(use: create)        // jogador
        bookings.delete(":bookingID", use: cancel)
    }

    func list(req: Request) async throws -> [BookingDTO] {
        let payload = try req.payload()
        guard let userID = payload.userID else { throw Abort(.unauthorized) }
        let q = Booking.query(on: req.db)
        switch payload.role {
        case .player:
            q.filter(\.$player.$id == userID)
        case .manager:
            q.join(Court.self, on: \Booking.$court.$id == \Court.$id)
             .join(Arena.self, on: \Court.$arena.$id == \Arena.$id)
             .filter(Arena.self, \.$manager.$id == userID)
        }
        return try await q.sort(\.$startsAt, .descending).all().map(\.dto)
    }

    func create(req: Request) async throws -> BookingDTO {
        try req.requireRole(.player)
        let body = try req.content.decode(CreateBookingRequest.self)
        guard body.endsAt > body.startsAt else { throw Abort(.badRequest, reason: "Horário final deve ser após o inicial") }
        guard let court = try await Court.find(body.courtID, on: req.db), court.isActive else {
            throw Abort(.notFound, reason: "Quadra não encontrada")
        }

        // Conflito de horário na mesma quadra
        let overlapping = try await Booking.query(on: req.db)
            .filter(\.$court.$id == body.courtID)
            .filter(\.$status != .cancelled)
            .filter(\.$startsAt < body.endsAt)
            .filter(\.$endsAt > body.startsAt)
            .count()
        guard overlapping == 0 else { throw Abort(.conflict, reason: "Quadra já reservada nesse horário") }

        let hours = body.endsAt.timeIntervalSince(body.startsAt) / 3600
        let booking = Booking(courtID: body.courtID, playerID: try req.payload().userID!,
                              startsAt: body.startsAt, endsAt: body.endsAt,
                              status: .confirmed, totalCents: Int((Double(court.pricePerHourCents) * hours).rounded()))
        try await booking.save(on: req.db)
        return booking.dto
    }

    func cancel(req: Request) async throws -> HTTPStatus {
        guard let booking = try await Booking.find(req.parameters.get("bookingID"), on: req.db) else { throw Abort(.notFound) }
        let payload = try req.payload()
        if payload.role == .player, booking.$player.id != payload.userID { throw Abort(.forbidden) }
        booking.status = .cancelled
        try await booking.save(on: req.db)
        return .noContent
    }
}
