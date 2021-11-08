//: [Previous](@previous)

import Foundation

class TaggedData {
    var tag: String
    var data: Data
    
    init(tag: String, data: Data) {
        self.tag = tag
        self.data = data
    }
    
}

class PersistentTaggedData: TaggedData {
    
    convenience init(tag: String, contentsOf url: URL) throws {
           let data = try Data(contentsOf: url)
           self.init(tag: tag, data: data)
       }
       
       // persistence
       func persist(to url: URL) throws {
           try self.data.write(to: url)
       }
}

class TaggedDataWithEncoding: TaggedData {
    var base64EncodedString: String {
        return data.base64EncodedString()
    }
}

/*
 //multiple inheritance not possible
class PersistedBase64Encoded: PersistentTaggedData, TaggedDataWithEncoding {
    
}
 */
