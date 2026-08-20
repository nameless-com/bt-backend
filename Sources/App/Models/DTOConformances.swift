import Vapor
import BTShared

// Os DTOs vivem em bt-shared; aqui só dizemos ao Vapor que são Content.
extension UserDTO: @retroactive Content {}
extension ArenaDTO: @retroactive Content {}
extension CourtDTO: @retroactive Content {}
extension BookingDTO: @retroactive Content {}
extension CreateArenaRequest: @retroactive Content {}
extension CreateBookingRequest: @retroactive Content {}
extension LoginRequest: @retroactive Content {}
extension RegisterRequest: @retroactive Content {}
extension AuthResponse: @retroactive Content {}
extension HealthResponse: @retroactive Content {}
