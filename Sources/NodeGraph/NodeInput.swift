
/**
 Defines how a node input communicates changes.
 */
public protocol NodeInputDelegate: class {
    func nodeInputDidUpdate<Input: NodeInputProtocol>(_: Input, value:Any?) -> Void
}

public protocol NodeInputProtocol: class {
    /**
     The key of this input for the node.
     */
    var key: String { get }
    
    var hasValue: Bool { get }
}

/**
 A type of input for a \c Node. This decides what type of input a node can accept.
 A node can accept more than one input by defining more of these.

 This class is well suited for subclassing so you can implement inputs for specific types.
*/
public protocol TypedInputProtocol: NodeInputProtocol {
    associatedtype ValueType: Equatable
    /**
     The current value of the input. The setter will run the validationBlock before
     trying to store the value.
     */
    var value: ValueType? { get set }

    /**
     The node that this input belongs to. Receives events regarding input changes.
     */
    var delegate: NodeInputDelegate? { get }
}


open class NodeInput<InputType: Equatable>: NodeInputProtocol {
    public typealias ValueType = InputType

    public var value: InputType? {
        didSet {
            delegate?.nodeInputDidUpdate(self, value: value)
        }
    }
    weak public var delegate: NodeInputDelegate?
    public var key: String = ""
    
    public var hasValue: Bool {
        return value != nil
    }

    required public init(key: String, delegate: NodeInputDelegate?) {
        self.key = key
        self.delegate = delegate
    }

    //MARK: - Hashable

    public static func == (lhs: NodeInput, rhs: NodeInput) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(unsafeBitCast(self, to: Int.self))
    }
}
