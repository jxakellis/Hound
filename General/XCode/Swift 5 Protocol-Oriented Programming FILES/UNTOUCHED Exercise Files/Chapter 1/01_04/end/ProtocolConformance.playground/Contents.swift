import Foundation

protocol Encrypting {
    func xor(key: UInt8) -> Self?
}

struct TaggedData: Encrypting {
    func xor(key: UInt8) -> TaggedData? {
        return nil
    }
}

/*
struct String: Encrypting {
}*/


extension String: Encrypting {
    func xor(key: UInt8) -> String? {
        String(bytes: self.utf8.map { $0 ^ key}, encoding: .utf8)
    }
}

let source = "Hello, Protocol!"
let target = source.xor(key: 42)

print(target ?? "Failed to encode")
print(target?.xor(key: 42) ?? "Failed to decode.")
