import Foundation

import Foundation

protocol Shape {
    var area: Double { get }
}

struct Square: Shape {
    let side: Double
    
    var area: Double {
        return side * side
    }
}

struct Rectangle: Shape {
    let width: Double
    let height: Double
    
    var area: Double {
        return width * height
    }
}

struct Rhombus: Shape {
    let d1: Double
    let d2: Double
    
    var area: Double {
        return (d1 * d2) / 2
    }
}

struct Circle: Shape {
    let radius: Double
    
    // A = π * r^2
    var area: Double {
        return .pi * radius * radius
    }
}
