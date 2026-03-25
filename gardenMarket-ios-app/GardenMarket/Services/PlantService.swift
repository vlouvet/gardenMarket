import Foundation

struct PlantService {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func getPlants() async throws -> [PlantProfile] {
        try await client.request(.listPlants)
    }

    func createPlant(_ request: CreatePlantRequest) async throws -> PlantProfile {
        try await client.request(.createPlant(request))
    }

    func updatePlant(id: Int, _ request: CreatePlantRequest) async throws -> PlantProfile {
        try await client.request(.updatePlant(id: id, request))
    }
}
