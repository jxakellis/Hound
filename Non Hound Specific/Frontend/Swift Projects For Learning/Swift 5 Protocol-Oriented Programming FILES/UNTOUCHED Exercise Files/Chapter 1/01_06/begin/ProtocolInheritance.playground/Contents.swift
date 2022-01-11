import Foundation

protocol Taggable {
    var tag: String {get}
    var data: Data { get }
    init(tag: String, data: Data)
}
