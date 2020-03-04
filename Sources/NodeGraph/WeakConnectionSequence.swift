
import Foundation

public class WeakConnectionSequence<T: AnyObject> {
    public struct WeakConnectionSetIterator: IteratorProtocol {
        private let connectionSet: WeakConnectionSequence<T>
        private var index = 0
        
        init(_ connectionSet: WeakConnectionSequence<T>) {
            self.connectionSet = connectionSet
        }
        
        mutating public func next() -> T? {
            guard index < connectionSet.connections.count else {
                return nil
            }
            
            defer { index += 1 }
            
            return connectionSet.connections[index].value
        }
    }
    
    fileprivate struct ConnectionWrapper {
        weak var value: T?
    }
    
    fileprivate var connections = [ConnectionWrapper]()
    
    let enforceUniqueness: Bool
    
    var count: Int {
        cleanUpConnections()
        return connections.count
    }
    
    init() {
        enforceUniqueness = false
    }
    
    init(enforceUniqueness: Bool) {
        self.enforceUniqueness = enforceUniqueness
    }
    
    @discardableResult func addConnection(_ connection: T) -> Bool {
        cleanUpConnections()
        
        if enforceUniqueness {
            let other = connections.first { (wrapper) -> Bool in
                guard let obj = wrapper.value else {
                    return false
                }
                
                return obj === connection
            }
            
            guard other == nil else {
                return false
            }
        }
        
        connections.append(ConnectionWrapper(value: connection))
        return true
    }
    
    func removeConnection(_ connectionToRemove: T) {
        cleanUpConnections()
        connections.removeAll { (entry) -> Bool in
            return entry.value === connectionToRemove
        }
    }
    
    private func cleanUpConnections() {
        connections.removeAll { (entry) -> Bool in
            return entry.value == nil
        }
    }
}

extension WeakConnectionSequence: Sequence {
    public func makeIterator() -> WeakConnectionSequence.WeakConnectionSetIterator {
        return WeakConnectionSetIterator(self)
    }
}
