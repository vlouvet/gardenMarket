import Foundation

struct AuthService {
    private let client: APIClient
    private let keychain: KeychainService

    init(client: APIClient = .shared, keychain: KeychainService = .shared) {
        self.client = client
        self.keychain = keychain
    }

    func login(email: String, password: String) async throws -> User {
        let tokens: AuthTokens = try await client.request(.login(email: email, password: password))
        keychain.accessToken = tokens.access
        keychain.refreshToken = tokens.refresh
        return try await client.request(.me)
    }

    func register(email: String, password: String, role: String) async throws -> User {
        let _: User = try await client.request(.register(email: email, password: password, role: role))
        return try await login(email: email, password: password)
    }

    func fetchCurrentUser() async throws -> User {
        try await client.request(.me)
    }

    func logout() {
        keychain.clearAll()
    }
}
