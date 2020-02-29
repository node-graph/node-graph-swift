import XCTest
@testable import NodeGraph

final class NodeOutputTests: XCTestCase {
    
    func testAddingConnection() {
        let output = NodeOutput<Int>()
        let input = NodeInput<Int>(key: "input", delegate: nil)
        
        output.addConnection(nodeInput: input)
        XCTAssertEqual(output.connections.count, 1)
    }
    
    func testRemovingConnection() {
        let output = NodeOutput<Int>()
        let input = NodeInput<Int>(key: "input", delegate: nil)
            
        output.addConnection(nodeInput: input)
        XCTAssertEqual(output.connections.count, 1)
        
        output.removeConnection(nodeInput: input)
        XCTAssertEqual(output.connections.count, 0)
    }
    
    func testEquality() {
        let output1 = NodeOutput<Int>()
        let output2 = NodeOutput<Int>()
        
        XCTAssertTrue(output1 == output1)
        XCTAssertFalse(output1 == output2)
    }
    
    static var allTests = [
        ("testAddingConnection", testAddingConnection),
        ("testRemovingConnection", testRemovingConnection)
    ]
}
