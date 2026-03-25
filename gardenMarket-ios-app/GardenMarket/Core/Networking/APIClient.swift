import Foundation

actor APIClient {
    static let shared = APIClient()

    var baseURL: URL {
        get {
            if let saved = UserDefaults.standard.string(forKey: "server_url"),
               let url = URL(string: saved) {
                return url
            }
            return URL(string: "http://192.168.1.42:8000")!
        }
        set {
            UserDefaults.standard.set(newValue.absoluteString, forKey: "server_url")
        }
    }

    private let session: URLSession
    private let keychain: KeychainService
    private let tokenRefresher: TokenRefresher
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(keychain: KeychainService = .shared) {
        self.session = URLSession.shared
        self.keychain = keychain
        self.tokenRefresher = TokenRefresher(keychain: keychain) {
            if let saved = UserDefaults.standard.string(forKey: "server_url"),
               let url = URL(string: saved) {
                return url
            }
            return URL(string: "http://192.168.1.42:8000")!
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = ISO8601DateFormatter().date(from: string) { return date }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            if let date = formatter.date(from: string) { return date }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: string) { return date }
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(string)")
        }
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await performRequest(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    func requestNoContent(_ endpoint: APIEndpoint) async throws {
        _ = try await performRequest(endpoint)
    }

    private func performRequest(_ endpoint: APIEndpoint, isRetry: Bool = false) async throws -> Data {
        let request = try buildRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response")
        }

        if httpResponse.statusCode == 401 && endpoint.requiresAuth && !isRetry {
            _ = try await tokenRefresher.refresh()
            return try await performRequest(endpoint, isRetry: true)
        }

        if httpResponse.statusCode == 204 {
            return Data()
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = parseErrorMessage(from: data) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.serverError(httpResponse.statusCode, message)
        }

        return data
    }

    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)
        if let queryItems = endpoint.queryItems {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if endpoint.requiresAuth, let token = keychain.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        return request
    }

    private func parseErrorMessage(from data: Data) -> String? {
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let detail = dict["detail"] as? String { return detail }
            if let firstError = dict.values.first as? [String] { return firstError.first }
        }
        return nil
    }
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        self.encodeClosure = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
