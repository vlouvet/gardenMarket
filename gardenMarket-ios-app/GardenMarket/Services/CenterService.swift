import Foundation

struct CenterService {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func getCenters() async throws -> [DistributionCenter] {
        try await client.request(.listCenters)
    }
}
