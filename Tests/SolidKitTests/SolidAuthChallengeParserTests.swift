import Testing
@testable import SolidKit

@Test func challengeParserReadsBearerChallenge() async throws {
    let parser = SolidAuthChallengeParser()
    let challenge = try #require(
        parser.parse(
            headerValue: #"Bearer realm="solid", scope="webid profile", error="invalid_token""#
        )
    )

    #expect(challenge.scheme == .bearer)
    #expect(challenge.realm == "solid")
    #expect(challenge.scopes == ["webid", "profile"])
    #expect(challenge.error == "invalid_token")
}
