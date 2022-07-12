/*:
 # Chapter Challenge: Game Logic
 ---
 ### Tasks
 1. Create two optional string variable called **lefthandWeapon** and **righthandWeapon**. Assigning them initial values is at your discretion.
 2. Use optional binding to unwrap both optionals in a single statement and debug both outcomes.
 3. Create a dictionary called **playerExp** and assign it some key-value pairs of type string and integer.
 4. Use a `for-in` loop to iterate over **playerExp** and capture the keys and values.
 5. Add a `guard` statement inside the `for-in` loop to make sure each player is at least level 1 to proceed. Don't forget to include the `continue` keyword.
 6. Use a switch statement to define the following cases:
    6a. exp is equal to 32
    6b. exp is between 200 and 500
    6c. Use value binding to store exp and check that it is greater than 500 using the `where` keyword
 
 [Previous Topic](@previous)
 
 */
// 1
var lefthandWeapon: String? = "Dagger"
var righthandWeapon: String? = "Knife"

// 2
if let lhW = lefthandWeapon, let rhW = righthandWeapon{
    print("In left hand: \(lhW) and in right hand: \(rhW)")
}
else if let lhW = lefthandWeapon{
    print("In left hand: \(lhW)")
}
else if let rhW = righthandWeapon{
    print("In right hand: \(rhW)")
}
else{
    print("No weapons in hand")
}

// 3
var playerExp: [String : Int] = ["Harrison": 233, "Steven": 489, "Bob": 0]

// 4
for (name, exp) in playerExp {
    //5
    guard exp > 0 else{
        print("\(name), you need some help")
        continue
    }
    
    //6
    
    switch exp {
    case 32:
        print("Looking good")
    case 201...500:
        print("Getting better every day...")
    case (let localExp) where localExp > 500:
        print("Time to level up!")
    default:
        print("Corrupted data found...")
    }
    
}

