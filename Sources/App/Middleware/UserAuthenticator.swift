import Vapor
import JWT
import Fluent
import BTShared

/// Payload do JWT emitido no login.
struct UserPayload: JWTPayload, Authenticatable {
    var sub: SubjectClaim
    var exp: ExpirationClaim
    var role: UserRole

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try exp.verifyNotExpired()
    }

    var userID: UUID? { UUID(uuidString: sub.value) }
}

struct UserAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        if let payload = try? await request.jwt.verify(bearer.token, as: UserPayload.self) {
            request.auth.login(payload)
        }
    }
}

extension Request {
    func payload() throws -> UserPayload { try auth.require(UserPayload.self) }

    func requireUser() async throws -> User {
        guard let id = try payload().userID, let user = try await User.find(id, on: db) else {
            throw Abort(.unauthorized)
        }
        return user
    }

    func requireRole(_ role: UserRole) throws {
        guard try payload().role == role else {
            throw Abort(.forbidden, reason: "Ação permitida apenas para \(role.rawValue)")
        }
    }
}
