import XCTest
@testable import NodeGraph

fileprivate class TestClass {
    let value: Int
    
    init() {
        value = 0
    }
    
    init(_ value: Int) {
        self.value = value
    }
}

final class WeakConnectionSetTests: XCTestCase {
    func testAddConnection() {
        let connectionSet = WeakConnectionSequence<TestClass>()
        
        let element = TestClass()
        connectionSet.addConnection(element)
        
        XCTAssertEqual(connectionSet.count, 1)
    }
    
    func testRemoveConnection() {
        let connectionSet = WeakConnectionSequence<TestClass>()
        
        let element = TestClass()
        connectionSet.addConnection(element)
        XCTAssertEqual(connectionSet.count, 1)
        
        connectionSet.removeConnection(element)
        XCTAssertEqual(connectionSet.count, 0)
    }
    
    func testNilConnectionIsAutomaticallyRemoved() {
        let connectionSet = WeakConnectionSequence<TestClass>()
        
        var element: TestClass? = TestClass()
        connectionSet.addConnection(element!)
        XCTAssertEqual(connectionSet.count, 1)
        
        element = nil
        
        XCTAssertEqual(connectionSet.count, 0)
    }
    
    func testConnectionSetIsIteratable() {
        let connectionSet = WeakConnectionSequence<TestClass>()
        
        let element1: TestClass = TestClass(100)
        let element2: TestClass = TestClass(200)
        let element3: TestClass = TestClass(300)
        connectionSet.addConnection(element1)
        connectionSet.addConnection(element2)
        connectionSet.addConnection(element3)
        XCTAssertEqual(connectionSet.count, 3)
        
        var expectedValue = 100
        for element in connectionSet {
            XCTAssertEqual(element.value, expectedValue)
            expectedValue += 100
        }
    }
    
    func testEncorcesUniquenessWhenSet() {
        let connectionSet = WeakConnectionSequence<TestClass>(enforceUniqueness: true)
        
        let element1: TestClass = TestClass(100)
        let element2: TestClass = TestClass(200)
        connectionSet.addConnection(element1)
        
        XCTAssertEqual(connectionSet.count, 1)
        XCTAssertFalse(connectionSet.addConnection(element1))
        XCTAssertTrue(connectionSet.addConnection(element2))
        XCTAssertEqual(connectionSet.count, 2)
    }
    
    func testDoesNotEncorcesUniquenessWhenNotSet() {
        let connectionSet = WeakConnectionSequence<TestClass>(enforceUniqueness: false)
        
        let element1: TestClass = TestClass(100)
        let element2: TestClass = TestClass(200)
        connectionSet.addConnection(element1)
        
        XCTAssertEqual(connectionSet.count, 1)
        XCTAssertTrue(connectionSet.addConnection(element1))
        XCTAssertTrue(connectionSet.addConnection(element2))
        XCTAssertEqual(connectionSet.count, 3)
    }
    
    static var allTests = [
        ("testAddConnection", testAddConnection)
    ]
}
