
/**
A representation of an output from a Node. An output can be named with a key to
signify what part of the result it carries.

An output has connections as weak references to instances of NodeInput.
*/
protocol NodeOutputProtocol: class, Hashable { // TODO: Do we need the protocol?
    associatedtype ResultType: Equatable
    associatedtype NodeInputType: NodeInputProtocol

    /**
     The key of this output, can be nil if the node only has one output.
     An example value for this could be the `R` output key in an `RGB` node.
     */
    var key: String? { get }
    var connections: WeakConnectionSequence<NodeInputType> { get set }

    /**
     Adds a downstream connection from this output to a @c NodeInput.
     */
    func addConnection(nodeInput: NodeInputType)

    /**
     Removes a downstream @c NodeInput connection from this output.
     */
    func removeConnection(nodeInput: NodeInputType)

    /**
     Sends the result to each downstream @c NodeInput connection in this output
     */
    func send(result: ResultType?)
}

class NodeOutput<OutputType: Equatable>: NodeOutputProtocol {
    typealias ResultType = OutputType
    typealias NodeInputType = NodeInput<ResultType>

    var key: String?
    var connections = WeakConnectionSequence<NodeInputType>(enforceUniqueness: true)

    func addConnection(nodeInput: NodeInputType) {
        connections.addConnection(nodeInput)
    }

    func removeConnection(nodeInput: NodeInputType) {
        connections.removeConnection(nodeInput)
    }

    func send(result: ResultType?) {
        for connection in connections {
            connection.value = result
        }
    }

    //MARK: - Hashable

    static func == (lhs: NodeOutput, rhs: NodeOutput) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(unsafeBitCast(self, to: Int.self))
    }
}



