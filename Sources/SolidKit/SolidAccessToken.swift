public struct SolidAccessToken: Sendable, Hashable {
    public let value: String
    public let tokenType: String

    public init(value: String, tokenType: String = "Bearer") {
        self.value = value
        self.tokenType = tokenType
    }
}
