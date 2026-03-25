import SwiftUI

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
                .frame(height: 100)
                .overlay {
                    Image(systemName: iconName)
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }

            Text(listing.displayType)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(listing.price.description)
                .font(.headline)
            + Text(" / \(listing.displayUnit)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                if listing.growerVerified == true {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.caption2)
                }
                if let distance = listing.distanceMiles {
                    Text("\(Int(distance)) mi")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if listing.quantityAvailable <= 2 {
                    Text("Low stock")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }

    private var iconName: String {
        switch listing.type {
        case "PRODUCE": return "carrot"
        case "SEEDS": return "leaf"
        case "CLIPPING": return "scissors"
        default: return "leaf"
        }
    }
}
