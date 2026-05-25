import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct SolidRequestSigner: Sendable {
    public init() {}

    public func signed(
        request: URLRequest,
        accessToken: SolidAccessToken,
        dpopProofJWT: String? = nil
    ) -> URLRequest {
        var signedRequest = request
        signedRequest.setValue("\(accessToken.tokenType) \(accessToken.value)", forHTTPHeaderField: "Authorization")
        if let dpopProofJWT, !dpopProofJWT.isEmpty {
            signedRequest.setValue(dpopProofJWT, forHTTPHeaderField: "DPoP")
        }
        return signedRequest
    }
}
