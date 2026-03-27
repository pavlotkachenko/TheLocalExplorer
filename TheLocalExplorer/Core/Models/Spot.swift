import Foundation

struct Spot: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let cuisine: String
    let priceLevel: Int
    let latitude: Double
    let longitude: Double
    let address: String
    let walkingTimeMinutes: Int
    let distanceMiles: Double
    let vibes: [String]
    let description: String
    let editorialQuote: String
    let editorName: String
    let editorAvatarURL: String
    let photoURLs: [String]
    let topDishes: [Dish]

    var priceLevelString: String {
        String(repeating: "$", count: priceLevel)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, cuisine
        case priceLevel = "price_level"
        case latitude, longitude, address
        case walkingTimeMinutes = "walking_time_minutes"
        case distanceMiles = "distance_miles"
        case vibes, description
        case editorialQuote = "editorial_quote"
        case editorName = "editor_name"
        case editorAvatarURL = "editor_avatar_url"
        case photoURLs = "photo_urls"
        case topDishes = "top_dishes"
    }
}

struct Dish: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Double

    var priceString: String {
        String(format: "$%.0f", price)
    }
}
