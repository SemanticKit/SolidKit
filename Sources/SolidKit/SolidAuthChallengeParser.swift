import Foundation

public struct SolidAuthChallengeParser: Sendable {
    public init() {}

    public func parse(headerValue: String) -> SolidAuthChallenge? {
        let trimmed = headerValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        guard let rawScheme = parts.first else {
            return nil
        }
        let scheme = parseScheme(String(rawScheme))

        let parameterText = parts.count > 1 ? String(parts[1]) : ""
        let parameters = parseParameters(parameterText)
        let realm = parameters["realm"]
        let scopes = parameters["scope"]?
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
            ?? []
        let error = parameters["error"]

        return SolidAuthChallenge(
            scheme: scheme,
            realm: realm,
            scopes: scopes,
            error: error,
            parameters: parameters
        )
    }

    private func parseScheme(_ raw: String) -> SolidAuthScheme {
        switch raw.lowercased() {
        case "bearer":
            return .bearer
        case "dpop":
            return .dpop
        default:
            return .unknown(raw)
        }
    }

    private func parseParameters(_ raw: String) -> [String: String] {
        guard !raw.isEmpty else {
            return [:]
        }

        var result: [String: String] = [:]
        var buffer = ""
        var inQuotes = false
        var segments: [String] = []

        for character in raw {
            if character == "\"" {
                inQuotes.toggle()
                buffer.append(character)
                continue
            }
            if character == ",", !inQuotes {
                segments.append(buffer)
                buffer = ""
                continue
            }
            buffer.append(character)
        }
        if !buffer.isEmpty {
            segments.append(buffer)
        }

        for segment in segments {
            let pair = segment.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard pair.count == 2 else {
                continue
            }
            let key = pair[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            var value = pair[1].trimmingCharacters(in: .whitespacesAndNewlines)
            if value.hasPrefix("\""), value.hasSuffix("\""), value.count >= 2 {
                value.removeFirst()
                value.removeLast()
            }
            result[key] = value
        }
        return result
    }
}
