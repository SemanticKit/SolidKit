public struct SolidAuthChallenge: Sendable, Hashable {
    public let scheme: SolidAuthScheme
    public let realm: String?
    public let scopes: [String]
    public let error: String?
    public let parameters: [String: String]

    public init(
        scheme: SolidAuthScheme,
        realm: String?,
        scopes: [String],
        error: String?,
        parameters: [String: String]
    ) {
        self.scheme = scheme
        self.realm = realm
        self.scopes = scopes
        self.error = error
        self.parameters = parameters
    }
}
