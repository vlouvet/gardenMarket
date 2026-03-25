import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let role: String

    var isGardener: Bool { role == "GARDENER" }
    var isConsumer: Bool { role == "CONSUMER" }
}

struct Profile: Codable {
    var addressLine1: String?
    var addressLine2: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    let lat: Double?
    let lon: Double?
    let geocodedAt: Date?
    let geocodeConfidence: String?
}

struct ProfileUpdate: Codable {
    var addressLine1: String
    var addressLine2: String
    var city: String
    var state: String
    var postalCode: String
    var country: String
}

struct AuthTokens: Codable {
    let access: String
    let refresh: String
}
