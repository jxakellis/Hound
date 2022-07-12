import Foundation

protocol Taggable {
    var tag: String {get}
    var data: Content { get }
    init(tag: String, data: Content)
}
