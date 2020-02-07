
/**
 Defines how a node input communicates changes.
 */
protocol NodeInputDelegate: class {
    func nodeInputDidUpdate<Input: NodeInputProtocol>(_: Input, value:Any?) -> Void
}

/**
 A type of input for a \c Node. This decides what type of input a node can accept.
 A node can accept more than one input by defining more of these.

 This class is well suited for subclassing so you can implement inputs for specific types.
*/
protocol NodeInputProtocol: class, Hashable {
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

    /**
     The optional key of this input for the node.
     */
    var key: String? { get }
}


class NodeInput<InputType: Equatable>: NodeInputProtocol {
    typealias ValueType = InputType

    var value: InputType? {
        didSet {
            delegate?.nodeInputDidUpdate(self, value: value)
        }
    }
    weak var delegate: NodeInputDelegate?
    var key: String?

    required init(key: String?, delegate: NodeInputDelegate) {
        self.key = key
        self.delegate = delegate
    }

    //MARK: - Hashable

    static func == (lhs: NodeInput, rhs: NodeInput) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(unsafeBitCast(self, to: Int.self))
    }
}
