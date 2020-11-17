import Foundation


/**
 Generics - Chapter Challenge
 
 The stack is a sequential container, that provides a Last-In-First-Out (LIFO) access.
 We can push new items onto the top of the stack. Accessing the most recently added is possible using peek() or pop().
 
 Your task is to implement a generic Stack that exposes the following methods and properties:
 - `push(element)`: adds the element to the top of the stack
 - `pop()`: returns and removes the top element from the stack; returns nil if the stack is empty
 - `peek()`: returns the top element or nil if the stack is empty
 - `count`: returns the number of elements in the stack
 - `isEmpty`: returns a Boolean value indicating whether the stack has no elements
 
 
 
 Hints:
 - Start by defining the protocol.
 - The `count` and `isEmpty` properties should be readonly.
 - Then, create the `Stack` type that adopts the protocol.
 - You can use an array as underlying storage.
 */

protocol StackProtocol {
    associatedtype T
    
    var stack: [T] { get set }
    
    var count: Int { get }
    var isEmpty: Bool { get }
}

extension StackProtocol{
    var count: Int {
        return stack.count
    }
    var isEmpty: Bool {
        if stack.count == 0{
        return true
        }
        else{
        return false
        }
    }
}

protocol StackManagement: StackProtocol {
    mutating func push(element: T)
    mutating func pop() -> T?
    func peek() -> T?
}

extension StackManagement{
    
    mutating func push(element: T){
        stack.append(element)
    }
    
    mutating func pop() -> T?{
        stack.popLast()
    }
    
    func peek() -> T?{
        stack.last
    }
}

struct Stack<TY>: StackManagement{
    typealias T = TY
    
    var stack: [T] = []
}

var stringStack = Stack<String>()

stringStack.push(element: "Hello")
stringStack.push(element: "Hi")

print(stringStack.pop() ?? "empty")
print(stringStack.pop() ?? "empty")
print(stringStack.pop() ?? "empty")
print(stringStack.count)



