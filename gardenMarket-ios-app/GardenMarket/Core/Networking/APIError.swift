import Foundation

enum APIError: LocalizedError, Equatable {
    case unauthorized
    case networkError(String)
    case serverError(Int, String)
    case decodingError(String)
    case invalidURL
    case noData

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Session expired. Please log in again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .decodingError(let message):
            return "Data error: \(message)"
        case .invalidURL:
            return "Invalid server URL."
        case .noData:
            return "No data received."
        }
    }
}
