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

    private(set) var inputs: Set<NodeInput<Int>>
    private(set) var outputs: Set<NodeOutput<Int>>

    init() {
        inputs = Set()
        outputs = Set()
        inputTrigger = .all
        
        inputs.insert(NodeInput<Int>(key: "lhs", delegate: self))
        inputs.insert(NodeInput<Int>(key: "rhs", delegate: self))

        outputs.insert(NodeOutput<Int>(key: "output"))
    }
    
    func process() {
        let lhs = input(forKey: "lhs")?.value ?? 0
        let rhs = input(forKey: "rhs")?.value ?? 0
        
        outputs.first!.send(result: lhs + rhs)
    }

    func cancel() {

    }

    func nodeInputDidUpdate<Input>(_: Input, value: Any?) where Input : NodeInputProtocol {
        guard canRun() else {
            return
        }
        
        process()
    }
}

final class NodeTests: XCTestCase {
    func testSettingInputValueTriggersDelegate() {
        let inputDelegateMock = NodeInputDelegateMock()
        let input = NodeInput<Int>(key: "input1", delegate: inputDelegateMock)
        XCTAssertFalse(inputDelegateMock.triggered)
        input.value = 13
        XCTAssertTrue(inputDelegateMock.triggered)
    }

    func testValuePropegatesToAllDownstreamInput() {
        let inputDelegateMock = NodeInputDelegateMock()
        let input1 = NodeInput<Int>(key: "input1", delegate: inputDelegateMock)
        let input2 = NodeInput<Int>(key: "input2", delegate: inputDelegateMock)
        let input3 = NodeInput<Int>(key: "input3", delegate: inputDelegateMock)
        
        let output = NodeOutput<Int>(key: "output")
        output.addConnection(nodeInput: input1)
        output.addConnection(nodeInput: input2)
        output.addConnection(nodeInput: input3)
        output.send(result: 13)
        
        XCTAssertTrue(input1.value == 13)
        XCTAssertTrue(input2.value == 13)
        XCTAssertTrue(input3.value == 13)
    }
    
    func testInputTriggerNoAutomaticProcessing() {
        let node = AddNodeMock()
        node.inputTrigger = .noAutomaticProcessing
        
        let downstreamDelegateMock = NodeInputDelegateMock()
        let downStreamInput = NodeInput<Int>(key: "downstream", delegate: downstreamDelegateMock)
        
        for output in node.outputs {
            output.addConnection(nodeInput: downStreamInput)
        }
        
        for input in node.inputs {
            input.value = 12
        }
        
        XCTAssertFalse(downstreamDelegateMock.triggered)
    }
    
    func testInputTriggerAny() {
        let value = 12
        let node = AddNodeMock()
        node.inputTrigger = .any
        
        let downstreamDelegateMock = NodeInputDelegateMock()
        let downStreamInput = NodeInput<Int>(key: "downstream", delegate: downstreamDelegateMock)
        
        for output in node.outputs {
            output.addConnection(nodeInput: downStreamInput)
        }
        
        node.input(forKey: "lhs")!.value = value
        
        XCTAssertTrue(downstreamDelegateMock.triggered)
        XCTAssertEqual(downStreamInput.value!, value)
    }
    
    func testInputTriggerAll() {
        let value = 12
        let result = 24
        let node = AddNodeMock()
        node.inputTrigger = .all
        
        let downstreamDelegateMock = NodeInputDelegateMock()
        let downStreamInput = NodeInput<Int>(key: "downstream", delegate: downstreamDelegateMock)
        
        for output in node.outputs {
            output.addConnection(nodeInput: downStreamInput)
        }
        
        node.input(forKey: "lhs")!.value = value
        XCTAssertFalse(downstreamDelegateMock.triggered)
        
        node.input(forKey: "rhs")!.value = value
        XCTAssertTrue(downstreamDelegateMock.triggered)
        XCTAssertEqual(downStreamInput.value!, result)
    }
    
    func testGettingInputForKey() {
        let node = AddNodeMock()
        
        XCTAssertNotNil(node.input(forKey: "lhs"))
        XCTAssertNotNil(node.input(forKey: "rhs"))
        XCTAssertNil(node.input(forKey: "aldjgoarjgpajrgoij"))
    }
    
    func testGettingOutputForKey() {
        let node = AddNodeMock()
        
        XCTAssertNotNil(node.output(forKey: "output"))
    }

    static var allTests = [
        ("testSettingInputValueTriggersDelegate", testSettingInputValueTriggersDelegate),
        ("testValuePropegatesToAllDownstreamInput", testValuePropegatesToAllDownstreamInput)
    ]
}
