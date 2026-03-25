import Foundation

struct DistributionCenter: Codable, Identifiable {
    let id: Int
    let name: String
    let addressLine1: String
    let addressLine2: String?
    let city: String
    let state: String
    let postalCode: String
    let country: String?
    let lat: Double?
    let lon: Double?
    let status: String?
    let capacityPerDay: Int?
    let pickupWindows: [String]?
    let remainingCapacity: Int?

    var fullAddress: String {
        [addressLine1, city, state, postalCode].joined(separator: ", ")
    }
}
