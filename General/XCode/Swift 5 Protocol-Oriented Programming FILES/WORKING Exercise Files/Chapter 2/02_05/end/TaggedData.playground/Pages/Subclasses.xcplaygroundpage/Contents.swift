import Foundation

// The subclass approach
// Although it works, it can't be used with value types. Besides, as we add new requirements, the number of subclasses increases, leading to type explosion
class TaggedData {
    var tag: String
    var data: Data
        
    init(tag: String, data: Data) {
        self.tag = tag
        self.data = data
    }
}

class PersistentTaggedData: TaggedData {
    // persistence
    func persist(to url: URL) throws {
        try self.data.write(to: url)
    }
    
    convenience init(tag: String, contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        self.init(tag: tag, data: data)
    }
}

class TaggedDataWithEncoding: TaggedData {
    // encoding
    var base64EncodedString: String {
        return data.base64EncodedString()
    }
}

// What if we need a type that supports both persistence and Base64 encoding?
// Since Swift dowsn't support multiple inheritance, we'd need to squeeze all the functionality into a base class.
// However, we alredy saw that assigning too many responsibilities to a class is a bad idea. It appears that we're stuck. So, what should we do now?
// No worries, protocols come to the rescue!

let taggedData = TaggedData(tag: "first",
                            data: Data(repeating: 0, count: 1))

print("\(taggedData.tag), \(taggedData.data)")
