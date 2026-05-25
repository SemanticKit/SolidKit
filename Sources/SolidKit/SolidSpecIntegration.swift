import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import AuditKit
import HttpSigKit
import PolicyKit
import URIKit
import WebIDKit

public struct SolidSpecIntegration: Sendable {
    private let uriNormalizer = URINormalizer()
    private let webIDParser = WebIDProfileParser()
    private let webIDVerifier = WebIDVerifier()
    private let requestSigner = SolidRequestSigner()
    private let auditEncoder = AuditRecordEncoder()

    public init() {}

    public func normalizeResourceIdentifier(_ value: String, strict: Bool = true) throws -> String {
        try uriNormalizer.normalize(uri: value, strict: strict)
    }

    public func verifyWebID(
        profileData: Data,
        baseIRI: String? = nil,
        request: WebIDVerificationRequest
    ) throws -> WebIDVerificationResult {
        let profile = try webIDParser.parse(profileData: profileData, baseIRI: baseIRI)
        let result = webIDVerifier.verify(profile: profile, request: request)
        if !result.isValid {
            throw SolidIntegrationError.webIDValidationFailed(result.issues)
        }
        return result
    }

    public func applyAuthenticationAndHTTPSignature(
        request: URLRequest,
        accessToken: SolidAccessToken?,
        dpopProofJWT: String? = nil,
        httpMessageSigner: HTTPMessageSigner,
        created: Int,
        expires: Int? = nil,
        nonce: String? = nil,
        signingFunction: (Data) throws -> Data
    ) throws -> URLRequest {
        guard let accessToken else {
            throw SolidIntegrationError.missingAuthorizationToken
        }
        guard request.url != nil else {
            throw SolidIntegrationError.missingRequestURL
        }

        let authSigned = requestSigner.signed(
            request: request,
            accessToken: accessToken,
            dpopProofJWT: dpopProofJWT
        )
        return try httpMessageSigner.applyingSignatureHeaders(
            to: authSigned,
            created: created,
            expires: expires,
            nonce: nonce,
            signingFunction: signingFunction
        )
    }

    public func evaluatePolicy(
        context: AccessContext,
        rules: [ZeroTrustPolicyRule]
    ) -> PolicyDecision {
        ZeroTrustPolicyEngine(rules: rules).evaluate(context)
    }

    public func encodeAuditRecord(
        timestamp: Date,
        actorID: String,
        action: String,
        resourceID: String,
        outcome: String,
        traceID: String,
        metadata: [String: String] = [:]
    ) throws -> String {
        try auditEncoder.encodeJSONLine(
            AuditRecord(
                timestamp: timestamp,
                actorID: actorID,
                action: action,
                resourceID: resourceID,
                outcome: outcome,
                traceID: traceID,
                metadata: metadata
            )
        )
    }
}
