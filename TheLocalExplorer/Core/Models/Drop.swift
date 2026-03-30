import Foundation

struct Drop: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let imageURL: String
    let spotIds: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, category
        case imageURL = "image_url"
        case spotIds = "spot_ids"
    }
}

struct DailyDropResponse: Codable {
    let hero: Drop
    let drops: [Drop]
    let nearbySpots: [Spot]

    enum CodingKeys: String, CodingKey {
        case hero, drops
        case nearbySpots = "nearby_spots"
    }
}
