import Foundation
import AuditKit
import Testing
@testable import SolidKit

@Test func specIntegrationCanTraceOperation() throws {
    let integration = SolidSpecIntegration()
    let tracer = InMemoryAuditTracer()

    let value: Int = integration.traced(
        tracer: tracer,
        traceID: "trace-2",
        spanID: "span-1",
        name: "solid.request",
        startedAt: Date(timeIntervalSince1970: 1_707_000_000),
        attributes: ["operation": "POST /inbox"]
    ) {
        42
    }

    #expect(value == 42)
    let spans = tracer.spans()
    #expect(spans.count == 1)
    #expect(spans[0].traceID == "trace-2")
    #expect(spans[0].name == "solid.request")
    #expect(spans[0].endedAt != nil)
}
