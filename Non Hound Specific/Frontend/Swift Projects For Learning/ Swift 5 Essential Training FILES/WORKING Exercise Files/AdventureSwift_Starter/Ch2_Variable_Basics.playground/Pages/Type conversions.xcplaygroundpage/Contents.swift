/*:
 # Type Conversions
 ---
 
 ## Topic Essentials
 Numeric values can be converted to other types using Int, Double, or Float class properties or with explicit syntax. Be aware that in some cases you will need to specify the result type if you want something specific. In other words, the compiler is very smart and will deliver the correct result type, but that might not be the type you want.
 
 ### Objectives
 + Understand explicit conversion and its syntax
 + Convert a Double to an Int and String respectively
 + Concatenate string literals and explicitly casted variables
 
 [Previous Topic](@previous)                                                 [Next Topic](@next)
 
*/
// Test variables
var currentGold_Double = 5.832

// Explicit conversions
var currentGold_Int: Int = Int(currentGold_Double)
print(currentGold_Int)
var currentGold_String = String(currentGold_Double)
print(currentGold_String)

// Inferred conversion with operators
var bankDeposit = 37 + 5.832
print(bankDeposit)
var bankDeposit_Explicit = currentGold_Double + Double(currentGold_Int)
print(bankDeposit_Explicit)
