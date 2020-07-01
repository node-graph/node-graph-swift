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

    public let inputs: [NodeInputProtocol]
    private(set) var outputs = Set<NodeOutput<Int>>()

    let lhs: NodeInput<Int>
    let rhs: NodeInput<Int>
    
    init() {
        inputTrigger = .all
        
        lhs = NodeInput<Int>(key: "lhs", delegate: nil)
        rhs = NodeInput<Int>(key: "rhs", delegate: nil)
        inputs = [lhs, rhs]
        
        lhs.delegate = self
        rhs.delegate = self
        
        outputs.insert(NodeOutput<Int>(key: "output"))
        
        
    }
    
    func process() {
        let lhsValue = lhs.value ?? 0
        let rhsValue = rhs.value ?? 0
        
        outputs.first!.send(result: lhsValue + rhsValue)
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
        
        node.rhs.value = 12
        node.lhs.value = 12
    
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
        
        node.lhs.value = value
        
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
        
        node.lhs.value = value
        XCTAssertFalse(downstreamDelegateMock.triggered)
        
        node.rhs.value = value
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
