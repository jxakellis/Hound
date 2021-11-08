import Foundation

protocol Taggable {
    var tag: String {get}
    var data: Data { get }
    init(tag: String, data: Data)
}

protocol TaggedPersistable: Taggable /*, CustomStringConvertible, Equatable*/{
    init(tag: String, contentsOf url: URL) throws
    func persist(to url: URL) throws
}

protocol TaggedEncodable: Taggable {
    var base64: String { get }
}
