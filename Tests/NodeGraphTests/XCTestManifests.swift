import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NodeTests.allTests),
        testCase(WeakConnectionSetTests.allTests)
    ]
}
#endif
