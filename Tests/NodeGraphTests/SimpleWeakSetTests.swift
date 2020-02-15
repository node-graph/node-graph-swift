import XCTest
@testable import NodeGraph

fileprivate class MockClass: Equatable {
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    static func == (lhs: MockClass, rhs: MockClass) -> Bool {
        return lhs.name == rhs.name
    }
}

final class SimpleWeakSetTests: XCTestCase {
    func testAddItem() {
        let set = SimpleWeakSet<MockClass>()
        let item = MockClass("mock1")
        set.add(item: item)
        
        XCTAssertEqual(set.count, 1)
    }
    
    func testRemoveItem() {
        let set = SimpleWeakSet<MockClass>()
        let object = MockClass("mock1")
        
        set.add(item: object)
        XCTAssertEqual(set.count, 1)
        
        set.remove(item:object)
        XCTAssertEqual(set.count, 0)
    }
    
    func testWeakItemIsRemovedAutomatically() {
        let set = SimpleWeakSet<MockClass>()
        
        if true {
            let object = MockClass("mock1")
            set.add(item: object)
            
            XCTAssertEqual(set.count, 1)
        }
        
        XCTAssertEqual(set.count, 0)
    }

    static var allTests = [
        ("testAddItem", testAddItem),
        ("testRemoveItem", testRemoveItem),
        ("testWeakItemIsRemovedAutomatically", testWeakItemIsRemovedAutomatically)
    ]
}
