import Vapor
import BTShared

func routes(_ app: Application) throws {
    app.get("health") { _ in HealthResponse(status: "ok", version: "0.1.0") }

    let api = app.grouped("api", "v1")
    try api.register(collection: AuthController())

    let protected = api.grouped(UserAuthenticator(), UserPayload.guardMiddleware())
    protected.get("me") { req -> UserDTO in
        let user = try await req.requireUser()
        return user.dto
    }
    try protected.register(collection: ArenaController())
    try protected.register(collection: BookingController())
}
