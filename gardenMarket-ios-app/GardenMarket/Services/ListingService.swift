import Foundation

struct ListingService {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func fetchListings(filter: ListingFilter? = nil) async throws -> [Listing] {
        try await client.request(.listListings(filter))
    }

    func fetchListing(id: Int) async throws -> Listing {
        try await client.request(.getListing(id: id))
    }

    func createListing(_ request: CreateListingRequest) async throws -> Listing {
        try await client.request(.createListing(request))
    }

    func updateListing(id: Int, _ request: UpdateListingRequest) async throws -> Listing {
        try await client.request(.updateListing(id: id, request))
    }
}
