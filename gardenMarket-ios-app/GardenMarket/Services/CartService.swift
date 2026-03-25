import Foundation

struct CartService {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func getCart() async throws -> Cart {
        try await client.request(.getCart)
    }

    func addItem(listingId: Int, quantity: Int) async throws -> Cart {
        try await client.request(.addToCart(listingId: listingId, quantity: quantity))
    }

    func removeItem(id: Int) async throws {
        try await client.requestNoContent(.removeCartItem(id: id))
    }
}
