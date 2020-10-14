
import Foundation

// First try: we implement all requirements in the TaggedData class, that:
// - stores the identifier-data pair,
// - can persist the data and restore it from persistence
// - returns the Base64-encoded string representation of the data
// Although this approach works, it goes against the Single Responsibility Principle, that tells us that each class should have a well-defined responsibility.
// So, let's try a more granular design.
class TaggedData {
    var tag: String
    var data: Data
        
    init(tag: String, data: Data) {
        self.tag = tag
        self.data = data
    }

    convenience init(tag: String, contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        self.init(tag: tag, data: data)
    }
    
    // persistence
    func persist(to url: URL) throws {
        try self.data.write(to: url)
    }

    // encoding
    var base64EncodedString: String {
        return data.base64EncodedString()
    }
}

let taggedData = TaggedData(tag: "first",
                            data: Data(repeating: 0, count: 1))

print("\(taggedData.tag), \(taggedData.data)")
