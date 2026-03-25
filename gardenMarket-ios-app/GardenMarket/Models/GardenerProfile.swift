import Foundation

struct GardenerProfile: Codable, Identifiable {
    let id: Int
    let bio: String?
    let payoutDetails: String?
    let verified: Bool
    let ratingAvg: Double
    let ratingCount: Int
}

struct UpdateGardenerRequest: Codable {
    var bio: String?
    var payoutDetails: String?
}
