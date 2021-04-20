import UIKit

let tuples: [(String, Int)] = [("str3",3),("str1",1),("str2",2),("str5",5),("str0",0),("str-7",-7),]

var tuplesCopy = tuples

tuplesCopy.sort { (arg1, arg2) -> Bool in
    
    let (str1, int1) = arg1
    let (str2, int2) = arg2
    
    if arg1.1 < arg2.1{
        return true
    }
    
    return false
}

print(tuples)
print(tuplesCopy)

