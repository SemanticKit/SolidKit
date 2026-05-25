public struct SolidAuthContext: Sendable, Hashable {
    public let statusCode: Int
    public let wwwAuthenticate: String?
    public let currentToken: SolidAccessToken?

    public init(statusCode: Int, wwwAuthenticate: String?, currentToken: SolidAccessToken? = nil) {
        self.statusCode = statusCode
        self.wwwAuthenticate = wwwAuthenticate
        self.currentToken = currentToken
    }
}
