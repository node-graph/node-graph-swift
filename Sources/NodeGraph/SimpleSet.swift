
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

fileprivate class WeakItemWrapper<ItemType: Equatable, Class> {
    weak var item: ItemType?
    init(item: ItemType) {
        self.item = item
    }
}

class SimpleWeakSet<ItemType: Equatable>: SimpleSet {
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
