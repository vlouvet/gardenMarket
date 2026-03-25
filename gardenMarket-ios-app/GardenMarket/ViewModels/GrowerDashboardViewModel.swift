import Foundation
import Observation

@Observable
final class GrowerDashboardViewModel {
    var plants: [PlantProfile] = []
    var listings: [Listing] = []
    var orders: [Order] = []
    var gardenerProfile: GardenerProfile?
    var isLoading = false
    var error: String?

    private let plantService = PlantService()
    private let listingService = ListingService()
    private let orderService = OrderService()
    private let gardenerService = GardenerService()

    func loadPlants() async {
        do {
            plants = try await plantService.getPlants()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createPlant(_ request: CreatePlantRequest) async {
        error = nil
        do {
            let plant = try await plantService.createPlant(request)
            plants.append(plant)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadListings() async {
        do {
            listings = try await listingService.fetchListings()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createListing(_ request: CreateListingRequest) async {
        error = nil
        do {
            let listing = try await listingService.createListing(request)
            listings.append(listing)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadGardenerOrders() async {
        do {
            orders = try await orderService.getGardenerOrders()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadGardenerProfile() async {
        do {
            let profiles = try await gardenerService.getGardeners()
            gardenerProfile = profiles.first
        } catch {
            // non-critical
        }
    }
}
