import Foundation

struct ProfileService {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func getProfile() async throws -> Profile {
        try await client.request(.getProfile)
    }

    func updateProfile(_ update: ProfileUpdate) async throws -> Profile {
        try await client.request(.updateProfile(update))
    }

    func upgrade() async throws -> User {
        try await client.request(.upgrade)
    }

    func getOnboardingStatus() async throws -> OnboardingStatus {
        try await client.request(.onboardingStatus)
    }
}
