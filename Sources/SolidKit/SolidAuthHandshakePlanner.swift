public struct SolidAuthHandshakePlanner: Sendable {
    private let parser = SolidAuthChallengeParser()

    public init() {}

    public func plan(context: SolidAuthContext) -> SolidAuthHandshakeStep {
        if context.statusCode < 400 {
            return .proceed
        }

        if context.statusCode == 401 {
            guard let header = context.wwwAuthenticate,
                  let challenge = parser.parse(headerValue: header) else {
                return .fail(reason: "Unauthorized response did not include a parseable WWW-Authenticate challenge.")
            }

            if context.currentToken == nil {
                return .acquireToken(scopes: challenge.scopes)
            }

            if challenge.error?.lowercased() == "invalid_token" {
                return .refreshToken(scopes: challenge.scopes)
            }

            return .fail(reason: "Unauthorized response rejected existing token without refresh hint.")
        }

        if context.statusCode == 403 {
            return .fail(reason: "Forbidden response indicates access was denied for the requested resource.")
        }

        return .fail(reason: "Unhandled Solid authentication status code: \(context.statusCode).")
    }
}
