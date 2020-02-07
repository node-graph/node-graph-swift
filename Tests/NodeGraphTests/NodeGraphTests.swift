import XCTest
@testable import NodeGraph

class Ey: NodeInputDelegate {
    var triggered = false
    func nodeInputDidUpdate<Input>(_: Input, value: Any?) where Input : NodeInputProtocol {
        triggered = true
    }
}

final class NodeGraphTests: XCTestCase {
    func testExample() {
        let ey = Ey()
        let input = NodeInput<Int>(key: nil, delegate: ey)
        XCTAssertFalse(ey.triggered)
        input.value = 13
        XCTAssertTrue(ey.triggered)
    }

    func testExample2() {
        let ey = Ey()
        let input = NodeInput<Int>(key: nil, delegate: ey)
        let output = NodeOutput<Int>()
        output.addConnection(nodeInput: input)
        output.send(result: 13)
        XCTAssertTrue(input.value == 13)
    }

    static var allTests = [
        ("testExample", testExample),
        ("testExample2", testExample2)
    ]
}
