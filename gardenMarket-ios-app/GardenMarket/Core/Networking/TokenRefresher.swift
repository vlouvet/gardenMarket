import Foundation

actor TokenRefresher {
    private var refreshTask: Task<String, Error>?
    private let keychain: KeychainService
    private let baseURLProvider: () -> URL

    init(keychain: KeychainService, baseURLProvider: @escaping () -> URL) {
        self.keychain = keychain
        self.baseURLProvider = baseURLProvider
    }

    func refresh() async throws -> String {
        if let existing = refreshTask {
            return try await existing.value
        }

        let task = Task<String, Error> {
            defer { refreshTask = nil }

            guard let refreshToken = keychain.refreshToken else {
                throw APIError.unauthorized
            }

            let url = baseURLProvider().appendingPathComponent("/api/accounts/token/refresh/")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["refresh": refreshToken])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError("Invalid response")
            }

            if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                keychain.clearAll()
                throw APIError.unauthorized
            }

            guard httpResponse.statusCode == 200 else {
                throw APIError.serverError(httpResponse.statusCode, "Token refresh failed")
            }

            struct RefreshResponse: Decodable {
                let access: String
            }

            let result = try JSONDecoder().decode(RefreshResponse.self, from: data)
            keychain.accessToken = result.access
            return result.access
        }

        refreshTask = task
        return try await task.value
    }
}
