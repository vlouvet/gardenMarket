import Foundation
import Observation

@Observable
final class ListingsViewModel {
    var listings: [Listing] = []
    var isLoading = false
    var error: String?
    var filter = ListingFilter()

    private let service = ListingService()

    func loadListings() async {
        isLoading = true
        error = nil
        do {
            listings = try await service.fetchListings(filter: filter)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
