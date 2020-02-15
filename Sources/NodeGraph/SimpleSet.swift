
protocol SimpleSet {
    associatedtype ItemType: Equatable
    
    var count: Int { get }
    
    func add(item: ItemType)
    
    func remove(item: ItemType)
}

class SimpleStrongSet<ItemType: Equatable>: SimpleSet {
    private var _items = [ItemType]()
    var count: Int {
        return _items.count
    }
    
    func add(item: ItemType) {
        guard !_items.contains(item) else {
            return
        }
        _items.append(item)
    }
    
    func remove(item: ItemType) {
        _items.removeAll { $0 == item }
    }
}

fileprivate class WeakItemWrapper<ItemType: AnyObject & Equatable> {
    weak var item: ItemType?
    init(item: ItemType) {
        self.item = item
    }
}

class SimpleWeakSet<ItemType: AnyObject & Equatable>: SimpleSet {
    private var _items = [WeakItemWrapper<ItemType>]()
    var count: Int {
        clean()
        return _items.count
    }
    
    var first: ItemType? {
        clean()
        return _items.first?.item
    }
    
    func add(item: ItemType) {
        clean()
        guard !(_items.contains { $0.item == item }) else {
            return
        }
        _items.append(WeakItemWrapper(item: item))
    }
    
    func remove(item: ItemType) {
        clean()
        _items.removeAll { $0.item == item }
    }
    
    func first(_ findClosure: (_ item: ItemType) -> Bool) -> ItemType? {
        clean()
        for wrapper in _items {
            if let item = wrapper.item, findClosure(item) {
                return item
            }
        }
        
        return nil
    }
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, ItemType) throws -> Result) rethrows -> Result {
        var result = initialResult
        clean()
        for wrapper in _items {
            if let item = wrapper.item {
                result = try nextPartialResult(result, item)
            }
        }
        
        return result
    }
    
    private func clean() {
        guard _items.count > 0 else {
            return
        }
        for i in _items.count-1...0 {
            let wrapper = _items[i]
            if wrapper.item == nil {
                _items.remove(at: i)
            }
        }
    }
}
