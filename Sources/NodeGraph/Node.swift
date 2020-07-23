
/**
 Decides what inputs need to be set in order for a node to process.
 */
public enum NodeInputTrigger: Int, Codable {
    /// The node does not automatically process anything, you manually have to call the -process method.
    case noAutomaticProcessing
    /// Process as soon as any input is set.
    case any
    /// All inputs have to be triggered between each run for the node to process.
    case all
    /// Same as NodeInputRequirementAll but keeps the value so next run can start whenever any input is set.
    case allAtLeastOnce
    /// The processing behaviour is custom and driven by the node itself.
    case custom
}


/**
 A Node in NodeGraph can have multiple inputs of varying types as well as many outputs of
 different types.

 Let't take an Add Node as the simplest example. It would require at least two
 inputs but the result would only be one value. Downstream nodes can be
 specified in the outputs property however they all receive the same result.

 Node example:

  20         4
   \        /
  --I0----I1--
 |             |
 |     Add     |
 | O = I0 + I1 |
 |             |
  ------O-----
        |
        24

 */
public protocol Node: NodeInputDelegate {
    associatedtype NodeOutputType: NodeOutputProtocol
    /**
     Specifies what inputs need to be set in order for the node to process.
     */
    var inputTrigger: NodeInputTrigger { get }

    /**
     The inputs of this node, inputs do not reference upstream nodes but keeps a
     result from an upstream node that this node can use when @c -process is called.
     */
    var inputs: [NodeInputProtocol] { get }

    /**
     All downstream connections out from this node. When -process is run the result
     will be fed to each NodeOutput.
     */
    var outputs: Set<NodeOutputType> { get }

    /**
     Processes the node with the current values stored in the inputs of this node.
     All outputs will be triggered with the result of this node's operation.

     This method will also be triggered internally based on the inputTrigger specified by the node.
     */
    func process()

    /**
     Cancels the current processing and stops the result from flowing to any
     downstream nodes. Also recursively cancels any downstream connections.
     */
    func cancel()
}

extension Node {
    public func canRun() -> Bool {
        switch inputTrigger {
        case .noAutomaticProcessing:
            return false
        case .any:
            return inputs.contains() { $0.hasValue }
        case .all:
            return !(inputs.contains() { !$0.hasValue })
        case .allAtLeastOnce:
            // TODO
            fallthrough
        case .custom:
            // TODO - maybe closure?
            fallthrough
        @unknown default:
            return false
        }
    }
    
    public func input(forKey key: String) -> NodeInputProtocol? {
        return (inputs.first(){ $0.key == key })
    }
    
    public func output(forKey key: String) -> NodeOutputType? {
        return (outputs.first(){ $0.key == key })
    }
}

public protocol DescribableNode: Node {
    /**
     Human readable name of the node.
     */
    var nodeName: String? { get }

    /**
     Describes what the node does or can be used for.
     */
    var nodeDescription: String? { get }
}
