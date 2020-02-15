
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
