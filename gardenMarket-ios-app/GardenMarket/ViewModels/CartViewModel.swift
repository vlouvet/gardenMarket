import Foundation
import Observation

@Observable
final class CartViewModel {
    var cart: Cart?
    var isLoading = false
    var error: String?

    private let service = CartService()

    var itemCount: Int { cart?.items.count ?? 0 }

    func loadCart() async {
        isLoading = true
        error = nil
        do {
            cart = try await service.getCart()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func addItem(listingId: Int, quantity: Int) async {
        error = nil
        do {
            cart = try await service.addItem(listingId: listingId, quantity: quantity)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func removeItem(id: Int) async {
        error = nil
        do {
            try await service.removeItem(id: id)
            await loadCart()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
}
