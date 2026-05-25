import Foundation
import AuditKit

extension SolidSpecIntegration {
    public func traced<T>(
        tracer: InMemoryAuditTracer,
        traceID: String,
        spanID: String,
        name: String,
        startedAt: Date,
        attributes: [String: String] = [:],
        operation: () throws -> T
    ) rethrows -> T {
        tracer.startSpan(
            traceID: traceID,
            spanID: spanID,
            name: name,
            startedAt: startedAt,
            attributes: attributes
        )
        defer {
            tracer.endSpan(traceID: traceID, spanID: spanID, endedAt: Date())
        }
        return try operation()
    }
}
