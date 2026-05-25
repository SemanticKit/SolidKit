import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpSigKit
import PolicyKit
import Testing
import WebIDKit
@testable import SolidKit

@Test func specIntegrationNormalizesUriSignsRequestEvaluatesPolicyAndWritesAudit() throws {
    let integration = SolidSpecIntegration()

    let normalized = try integration.normalizeResourceIdentifier(
        "HTTPS://BÜCHER.Example:443/private/./docs/../card"
    )
    #expect(normalized == "https://xn--bcher-kva.example/private/card")

    let profile = """
    @prefix foaf: <http://xmlns.com/foaf/0.1/> .
    @prefix cert: <http://www.w3.org/ns/auth/cert#> .
    @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

    <https://alice.example/profile/card> foaf:primaryTopic <https://alice.example/profile/card#me> .
    <https://alice.example/profile/card#me> a foaf:Person ;
        cert:key [ cert:modulus "00A1B2C3D4" ; cert:exponent "65537"^^xsd:integer ] .
    """
    let webIDResult = try integration.verifyWebID(
        profileData: Data(profile.utf8),
        request: WebIDVerificationRequest(
            expectedWebID: "https://alice.example/profile/card#me",
            expectedProfileDocumentIRI: "https://alice.example/profile/card",
            requiredPublicKey: WebIDPublicKey(modulusHex: "00a1b2c3d4", exponent: 65537)
        )
    )
    #expect(webIDResult.isValid)

    var request = URLRequest(url: try #require(URL(string: "https://pod.example/inbox")))
    request.httpMethod = "POST"

    let httpSigner = HTTPMessageSigner(
        keyID: "solid-key-1",
        coveredComponents: [.method, .authority, .path, .authorization]
    )
    let signed = try integration.applyAuthenticationAndHTTPSignature(
        request: request,
        accessToken: SolidAccessToken(value: "abc123", tokenType: "DPoP"),
        dpopProofJWT: "proof.jwt.value",
        httpMessageSigner: httpSigner,
        created: 1_707_000_000
    ) { payload in
        Data(("sig:" + String(decoding: payload, as: UTF8.self)).utf8)
    }
    #expect(signed.value(forHTTPHeaderField: "Authorization") == "DPoP abc123")
    #expect(signed.value(forHTTPHeaderField: "DPoP") == "proof.jwt.value")
    #expect(signed.value(forHTTPHeaderField: "Signature-Input")?.contains("keyid=\"solid-key-1\"") == true)
    #expect(signed.value(forHTTPHeaderField: "Signature")?.hasPrefix("sig1=:") == true)

    let policyDecision = integration.evaluatePolicy(
        context: AccessContext(
            subjectID: "alice",
            resourceID: "https://pod.example/inbox",
            action: "write",
            authTier: .high,
            deviceManaged: true,
            networkTrusted: true,
            scopes: ["solid:write"],
            timestamp: Date(timeIntervalSince1970: 1_707_000_000)
        ),
        rules: [
            ZeroTrustPolicyRule(
                id: "write-pod",
                actions: ["write"],
                requiredAuthTier: .high,
                requiresManagedDevice: true,
                requiresTrustedNetwork: true,
                requiredScopes: ["solid:write"]
            )
        ]
    )
    #expect(policyDecision.isAllowed)

    let line = try integration.encodeAuditRecord(
        timestamp: Date(timeIntervalSince1970: 1_707_000_000),
        actorID: "alice",
        action: "write",
        resourceID: "https://pod.example/inbox",
        outcome: "allow",
        traceID: "trace-1",
        metadata: ["module": "solid"]
    )
    #expect(line.contains("\"traceID\":\"trace-1\""))
    #expect(line.contains("\"actorID\":\"alice\""))
    #expect(line.hasSuffix("\n"))
}
