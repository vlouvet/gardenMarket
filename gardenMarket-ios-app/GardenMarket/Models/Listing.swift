import Foundation

struct Listing: Codable, Identifiable {
    let id: Int
    let plant: Int
    let type: String
    let unit: String
    let price: FlexDecimal
    let quantityAvailable: Int
    let status: String
    let isHidden: Bool?
    let pickupWindow: String?
    let pickupDays: [String]?
    let createdAt: Date?
    let inStock: Bool?
    let distanceMiles: Double?
    let grownWithinMiles: Int?
    let growerVerified: Bool?
    let growerRating: Double?

    var displayType: String {
        switch type {
        case "PRODUCE": return "Produce"
        case "SEEDS": return "Seeds"
        case "CLIPPING": return "Clipping"
        default: return type.capitalized
        }
    }

    var displayUnit: String {
        switch unit {
        case "lb": return "lb"
        case "each": return "ea"
        case "gram": return "g"
        case "bundle": return "bundle"
        default: return unit
        }
    }
}

struct ListingFilter {
    var type: String?
    var growMethod: String?
    var pickupDay: String?
    var inStock: Bool?
    var lat: Double?
    var lon: Double?
    var address: String?

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let type { items.append(.init(name: "type", value: type)) }
        if let growMethod { items.append(.init(name: "grow_method", value: growMethod)) }
        if let pickupDay { items.append(.init(name: "pickup_day", value: pickupDay)) }
        if let inStock, inStock { items.append(.init(name: "in_stock", value: "1")) }
        if let lat { items.append(.init(name: "lat", value: String(lat))) }
        if let lon { items.append(.init(name: "lon", value: String(lon))) }
        if let address { items.append(.init(name: "address", value: address)) }
        return items
    }
}

struct CreateListingRequest: Codable {
    let plant: Int
    let type: String
    let unit: String
    let price: String
    let quantityAvailable: Int
    let pickupWindow: String?
    let pickupDays: [String]?
}

struct UpdateListingRequest: Codable {
    var price: String?
    var quantityAvailable: Int?
    var pickupWindow: String?
    var pickupDays: [String]?
    var status: String?
}

/// Handles Decimal fields from DRF which may arrive as string or number.
struct FlexDecimal: Codable, CustomStringConvertible {
    let value: Decimal

    var description: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }

    init(_ value: Decimal) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self), let d = Decimal(string: str) {
            self.value = d
        } else if let d = try? container.decode(Decimal.self) {
            self.value = d
        } else if let d = try? container.decode(Double.self) {
            self.value = Decimal(d)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode decimal")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(value)")
    }
}
