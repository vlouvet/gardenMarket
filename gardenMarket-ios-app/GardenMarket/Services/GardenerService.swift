import Foundation

struct GardenerService {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func getGardeners() async throws -> [GardenerProfile] {
        try await client.request(.listGardeners)
    }

    func getGardener(id: Int) async throws -> GardenerProfile {
        try await client.request(.getGardener(id: id))
    }

    func updateGardener(id: Int, _ request: UpdateGardenerRequest) async throws -> GardenerProfile {
        try await client.request(.updateGardener(id: id, request))
    }
}
