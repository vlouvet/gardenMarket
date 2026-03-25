import Foundation

struct Cart: Codable, Identifiable {
    let id: Int
    let items: [CartItem]
}

struct CartItem: Codable, Identifiable {
    let id: Int
    let listing: Int
    let quantity: Int
}
