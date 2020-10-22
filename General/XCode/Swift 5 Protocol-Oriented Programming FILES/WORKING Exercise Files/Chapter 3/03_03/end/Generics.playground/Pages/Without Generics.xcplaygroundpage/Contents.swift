import Foundation


func equals(lhs: Int, rhs: Int) -> Bool {
    // The iplementation is straightforward
    return lhs == rhs
}

print(equals(lhs: 3, rhs: 4))

/*
 It works, except that it only lets us compare two Int values.
 Let's try to use the equals function with floating point values:
 */
//print(equals(lhs: 1.4, rhs: 1.5))

// As expected, we get a compiler error.
// So, we create a new version which accepts values of type Double
func equals(lhs: Double, rhs: Double) -> Bool {
    return lhs == rhs
}

// This works with double types
equals(lhs: 2, rhs: 3.1)

// But what about Float types?
// I'm going to declare two float contants.
let pi: Float = 3.14
let e: Float = 2.71

// print(equals(lhs: pi, rhs: e))
// We need to explicitely specify the type, as Swift assumes that every floating point value is a Double

// So, this function won’t work with Float types.
// We end up creating yet another function which accepts Float types.

func equals(lhs: Float, rhs: Float) -> Bool {
    return lhs == rhs
}

equals(lhs: pi, rhs: e)
