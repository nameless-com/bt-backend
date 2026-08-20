@testable import App
import XCTVapor
import BTShared

final class AppTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
    }
    override func tearDown() async throws { try await app.asyncShutdown() }

    func testHealth() async throws {
        try await app.test(.GET, "health") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try res.content.decode(HealthResponse.self).status, "ok")
        }
    }

    func testPlayerFlow() async throws {
        var token = ""
        try await app.test(.POST, "api/v1/auth/login", beforeRequest: { req in
            try req.content.encode(LoginRequest(email: "jogador@bt.dev", password: "123456"))
        }) { res async in
            XCTAssertEqual(res.status, .ok)
            token = (try? res.content.decode(AuthResponse.self).token) ?? ""
        }
        try await app.test(.GET, "api/v1/arenas", headers: ["Authorization": "Bearer \(token)"]) { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try res.content.decode([ArenaDTO].self).count, 1)
        }
    }
}
