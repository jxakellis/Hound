
import Foundation

func callback(completionHandler: @escaping (String) -> Void){
    print(1)
    print(2)
     completionHandler("str")
    print(3)
    completionHandler("asdfasf")
}

callback { str in
    print(str)
}
