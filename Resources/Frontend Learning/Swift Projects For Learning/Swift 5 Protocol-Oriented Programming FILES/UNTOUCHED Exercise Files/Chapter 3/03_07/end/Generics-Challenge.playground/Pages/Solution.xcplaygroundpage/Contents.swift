//import Foundation

public protocol StackProtocol {
    associatedtype E
    /// Adds the element to the top of the stack
    mutating func push(_ item: E)
    
    /// Returns and removes the top element from the stack; returns nil if the stack is empty
    mutating func pop() -> E?

    /// Returns the top element or nil if the stack is empty
    func peek() -> E?

    /// Returns the number of elements in the stack
    var count: Int {get}
    
    /// Returns a Boolean value indicating whether the stack has no elements
    var isEmpty: Bool {get}
}

public struct Stack<T>: StackProtocol {
    private var storage = [T]()
    
    /// Adds the element to the top of the stack
    public mutating func push(_ item: T) {
        storage.append(item)
    }
    
    /// Returns and removes the top element from the stack; returns nil if the stack is empty
    public mutating func pop() -> T? {
        storage.popLast()
    }

    /// Returns the top element or nil if the stack is empty
    public func peek() -> T? {
        storage.last
    }

    /// Returns the number of elements in the stack
    public var count: Int {
        storage.count
    }
    
    /// Returns a Boolean value indicating whether the stack has no elements
    public var isEmpty: Bool {
        storage.isEmpty
    }
}

var stringStack = Stack<String>()
stringStack.push("Hello")
stringStack.push(", ")
stringStack.push("Swift")

print(stringStack.pop() ?? "empty")
print(stringStack.pop() ?? "empty")
print(stringStack.peek() ?? "empty")
print(stringStack.count)

