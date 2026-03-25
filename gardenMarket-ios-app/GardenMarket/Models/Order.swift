import Foundation

struct Order: Codable, Identifiable {
    let id: Int
    let status: String
    let distributionCenter: Int?
    let pickupWindow: String?
    let pickupDate: String?
    let mockPaymentReference: String?
    let stripePaymentIntentId: String?
    let paymentStatus: String?
    let checkinCode: String?
    let checkedInAt: Date?
    let createdAt: Date?
    let items: [OrderItem]?

    var displayStatus: String {
        switch status {
        case "CREATED": return "Created"
        case "AWAITING_PICKUP_SCHEDULING": return "Awaiting Pickup"
        case "SCHEDULED": return "Scheduled"
        case "COMPLETE": return "Complete"
        case "CANCELLED": return "Cancelled"
        default: return status
        }
    }

    var isPaid: Bool {
        paymentStatus == "paid" || paymentStatus == "succeeded"
    }
}

struct OrderItem: Codable, Identifiable {
    let id: Int
    let listing: Int
    let quantity: Int
    let priceAtPurchase: FlexDecimal
}
