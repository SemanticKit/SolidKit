public enum SolidAuthScheme: Sendable, Hashable {
    case bearer
    case dpop
    case unknown(String)
}
