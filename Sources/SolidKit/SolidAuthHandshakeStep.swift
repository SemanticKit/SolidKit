public enum SolidAuthHandshakeStep: Sendable, Hashable {
    case proceed
    case acquireToken(scopes: [String])
    case refreshToken(scopes: [String])
    case fail(reason: String)
}
