
import Foundation

var nums = [1,3,4,6,12,5,3214,51346,2]
for (indexx, num) in nums.enumerated().reversed() where num % 2 == 0 {
    nums.remove(at: indexx)
}
print(nums)
