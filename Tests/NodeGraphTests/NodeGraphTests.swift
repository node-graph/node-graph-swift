import XCTest
@testable import NodeGraph

class NodeInputDelegateMock: NodeInputDelegate {
    var triggered = false
    func nodeInputDidUpdate<Input>(_: Input, value: Any?) where Input : NodeInputProtocol {
        triggered = true
    }
}

class AddNodeMock: Node {

    typealias NodeInputType = NodeInput<Int>
    typealias NodeOutputType = NodeOutput<Int>

    var inputTrigger: NodeInputTrigger

    var inputs: Set<NodeInput<Int>>

    var outputs: Set<NodeOutput<Int>>

    init() {
        inputs = Set()
        outputs = Set()

        super.init()
        inputs.insert(NodeInput<Int>(key: "lhs", delegate: self))
        inputs.insert(NodeInput<Int>(key: "rhs", delegate: self))

        outputs.insert(NodeOutput<Int>())
    }

    func process() {
        // TODO: Get specific input
        guard let lhs = (inputs.first(){ $0.key! == "lhs" })?.value else {
            return
        }
    }

    func cancel() {

    }

    func nodeInputDidUpdate<Input>(_: Input, value: Any?) where Input : NodeInputProtocol {
        let shouldProcess = inputs.reduce(true) { (result, input) -> Bool in
            return result && input.value != nil
        }
        guard shouldProcess else {
            return
        }
        process()
    }
}

final class NodeGraphTests: XCTestCase {
    func testSettingInputValueTriggersDelegate() {
        let inputDelegateMock = NodeInputDelegateMock()
        let input = NodeInput<Int>(key: nil, delegate: inputDelegateMock)
        XCTAssertFalse(inputDelegateMock.triggered)
        input.value = 13
        XCTAssertTrue(inputDelegateMock.triggered)
    }

    func testExample2() {
        let inputDelegateMock = NodeInputDelegateMock()
        let input = NodeInput<Int>(key: nil, delegate: inputDelegateMock)
        let output = NodeOutput<Int>()
        output.addConnection(nodeInput: input)
        output.send(result: 13)
        XCTAssertTrue(input.value == 13)
    }

    func testNode() {

    }


    static var allTests = [
        ("testSettingInputValueTriggersDelegate", testSettingInputValueTriggersDelegate),
        ("testExample2", testExample2)
    ]
}
