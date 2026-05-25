public enum SolidIntegrationError: Error, Equatable {
    case missingRequestURL
    case missingAuthorizationToken
    case webIDValidationFailed([String])
}
