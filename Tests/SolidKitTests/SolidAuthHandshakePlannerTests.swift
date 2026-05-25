import Testing
@testable import SolidKit

@Test func handshakePlannerRequestsNewTokenWithoutExistingToken() async throws {
    let planner = SolidAuthHandshakePlanner()
    let step = planner.plan(
        context: SolidAuthContext(
            statusCode: 401,
            wwwAuthenticate: #"Bearer realm="solid", scope="webid profile""#,
            currentToken: nil
        )
    )

    if case .acquireToken(let scopes) = step {
        #expect(scopes == ["webid", "profile"])
    } else {
        Issue.record("Expected token acquisition step.")
    }
}

@Test func handshakePlannerRequestsRefreshWhenServerReportsInvalidToken() async throws {
    let planner = SolidAuthHandshakePlanner()
    let step = planner.plan(
        context: SolidAuthContext(
            statusCode: 401,
            wwwAuthenticate: #"Bearer realm="solid", scope="webid", error="invalid_token""#,
            currentToken: SolidAccessToken(value: "expired")
        )
    )

    if case .refreshToken(let scopes) = step {
        #expect(scopes == ["webid"])
    } else {
        Issue.record("Expected token refresh step.")
    }
}
