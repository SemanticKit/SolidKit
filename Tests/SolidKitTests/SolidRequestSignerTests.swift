import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import SolidKit

@Test func requestSignerAddsAuthorizationAndDpopHeaders() async throws {
    let signer = SolidRequestSigner()
    let request = URLRequest(url: try #require(URL(string: "https://pod.example/resource")))
    let signed = signer.signed(
        request: request,
        accessToken: SolidAccessToken(value: "abc123", tokenType: "DPoP"),
        dpopProofJWT: "proof.jwt.value"
    )

    #expect(signed.value(forHTTPHeaderField: "Authorization") == "DPoP abc123")
    #expect(signed.value(forHTTPHeaderField: "DPoP") == "proof.jwt.value")
}
