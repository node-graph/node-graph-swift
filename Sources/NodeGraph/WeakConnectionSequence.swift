
import Foundation

class WeakConnectionSequence<T: AnyObject> {
    struct WeakConnectionSetIterator: IteratorProtocol {
        private let connectionSet: WeakConnectionSequence<T>
        private var index = 0
        
        init(_ connectionSet: WeakConnectionSequence<T>) {
            self.connectionSet = connectionSet
        }
        
        mutating func next() -> T? {
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
    
    var count: Int {
        cleanUpConnections()
        return connections.count
    }
    
    func addConnection(_ connection: T) {
        cleanUpConnections()
        connections.append(ConnectionWrapper(value: connection))
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
    func makeIterator() -> WeakConnectionSequence.WeakConnectionSetIterator {
        return WeakConnectionSetIterator(self)
    }
}
