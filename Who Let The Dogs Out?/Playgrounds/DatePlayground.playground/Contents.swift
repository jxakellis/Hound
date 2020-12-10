import UIKit

/*
let pastDate = Date()
print(pastDate)

let currentDate = Date(timeInterval: 1800, since: pastDate)

var testInterval = TimeInterval(60)

var timeElapsedSincePast = currentDate.timeIntervalSince(pastDate)

var timesIntervalNeedsAdded: Int {
    return Int((timeElapsedSincePast/testInterval).rounded(.up))
}

print(timesIntervalNeedsAdded)
*/

let pastDate = Date()
print("past time    " + pastDate.description(with: .current))

let currentDate = Date(timeInterval: 120, since: Date())
print("current time     " + currentDate.description(with: .current))

let testInterval = TimeInterval(60)

var executionTime: Date {
    let timeElapsedSincePast = currentDate.timeIntervalSince(pastDate)
    let timeIntervalNeedsAdded = Int((timeElapsedSincePast/testInterval).rounded())
    
    return Date(timeInterval: (Double(timeIntervalNeedsAdded) * testInterval), since: pastDate)
}

print("execution time       " + executionTime.description(with: .current))
