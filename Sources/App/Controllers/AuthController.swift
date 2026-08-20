import Vapor
import Fluent
import JWT
import BTShared

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    func register(req: Request) async throws -> AuthResponse {
        let body = try req.content.decode(RegisterRequest.self)
        guard body.password.count >= 6 else { throw Abort(.badRequest, reason: "Senha precisa ter ao menos 6 caracteres") }
        if try await User.query(on: req.db).filter(\.$email == body.email.lowercased()).first() != nil {
            throw Abort(.conflict, reason: "E-mail já cadastrado")
        }
        let user = User(name: body.name, email: body.email.lowercased(),
                        passwordHash: try Bcrypt.hash(body.password), role: body.role)
        try await user.save(on: req.db)
        return try await token(for: user, req: req)
    }

    func login(req: Request) async throws -> AuthResponse {
        let body = try req.content.decode(LoginRequest.self)
        guard let user = try await User.query(on: req.db).filter(\.$email == body.email.lowercased()).first(),
              try Bcrypt.verify(body.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "E-mail ou senha inválidos")
        }
        return try await token(for: user, req: req)
    }

    private func token(for user: User, req: Request) async throws -> AuthResponse {
        let payload = UserPayload(
            sub: .init(value: try user.requireID().uuidString),
            exp: .init(value: Date().addingTimeInterval(60 * 60 * 24 * 30)),
            role: user.role
        )
        return AuthResponse(token: try await req.jwt.sign(payload), user: user.dto)
    }
}
