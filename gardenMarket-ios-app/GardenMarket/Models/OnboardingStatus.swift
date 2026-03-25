import Foundation

struct OnboardingStatus: Codable {
    let profileComplete: Bool
    let payoutComplete: Bool
    let firstListing: Bool

    var allComplete: Bool { profileComplete && payoutComplete && firstListing }
}
