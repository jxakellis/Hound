import Foundation

func equals<T: Equatable>(lhs: T, rhs: T) -> Bool{
    return lhs == rhs
}

equals(lhs: "ab", rhs: "ab")

equals(lhs: 32.3, rhs: 342.2)

let d1 = Data(repeating: 1, count: 10)
let d2 = Data(repeating: 1, count: 10)

equals(lhs: d1, rhs: d2)
