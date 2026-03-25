import Foundation

struct PlantProfile: Codable, Identifiable {
    let id: Int
    let gardener: Int
    let name: String
    let species: String?
    let description: String?
    let tags: String?
    let growMethod: String?

    var displayGrowMethod: String {
        switch growMethod {
        case "SOIL": return "Soil"
        case "HYDROPONIC": return "Hydroponic"
        case "AQUAPONIC": return "Aquaponic"
        case "ORGANIC": return "Organic"
        default: return growMethod ?? "Unknown"
        }
    }
}

struct CreatePlantRequest: Codable {
    let gardener: Int
    let name: String
    let species: String
    let description: String
    let tags: String
    let growMethod: String
}
