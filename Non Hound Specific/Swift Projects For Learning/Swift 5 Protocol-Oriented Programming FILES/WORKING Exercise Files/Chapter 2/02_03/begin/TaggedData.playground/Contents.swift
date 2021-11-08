import Foundation

class TaggedData {
    var tag: String
    var data: Data
    
    init(tag: String, data: Data){
        self.data = data
        self.tag = tag
    }
    
    func persist(to url: URL) throws {
        try self.data.write(to: url)
    }
    
    convenience init(tag: String, contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        self.init(tag: tag, data: data)
    }
    
    var base64EncodedString: String {
        return data.base64EncodedString()
    }
}
