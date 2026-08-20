import Vapor
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import JWT
import BTShared

public func configure(_ app: Application) async throws {
    // JSON igual ao BTJSON do bt-shared (datas ISO-8601) — contrato único com os apps.
    let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
    let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    // Banco: DATABASE_URL (Postgres) em produção; SQLite local em dev/test.
    if let url = Environment.get("DATABASE_URL") {
        try app.databases.use(.postgres(url: url), as: .psql)
    } else if app.environment == .testing {
        app.databases.use(.sqlite(.memory), as: .sqlite)
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }

    // JWT
    let secret = Environment.get("JWT_SECRET") ?? "dev-secret-troque-em-producao"
    await app.jwt.keys.add(hmac: HMACKey(from: secret), digestAlgorithm: .sha256)

    // CORS (útil se um dia houver web)
    app.middleware.use(CORSMiddleware(configuration: .default()))

    app.migrations.add(CreateUser())
    app.migrations.add(CreateArena())
    app.migrations.add(CreateCourt())
    app.migrations.add(CreateBooking())
    if app.environment != .production { app.migrations.add(SeedDevData()) }
    try await app.autoMigrate()

    try routes(app)
}
