import Foundation

struct StringWrapper {
    var storage: String
}

struct IntWrapper {
    var storage: Int
}

struct DateWrapper {
    var storage: Date
}

struct Wrapper<T: Equatable> {
    var storage: T
    init(_ value: T) {
        storage = value
    }
}

/*
 Using the generic version is straightforward
 */
let piWrapped = Wrapper<Double>(Double.pi)

/*
 In most cases, we can even skip the placeholder type.
 The compiler will figure out the type based on the arguments.
 Type inference works by examining the provided values while compiling the code.
 */
let piWrapped2 = Wrapper(Double.pi)

/*
 Now, let's create a new instance that wraps a String
 */
let stringWrapped = Wrapper("POP")

/*
 Or a Date wrapper
 */
let dateWrapped = Wrapper(Date())
