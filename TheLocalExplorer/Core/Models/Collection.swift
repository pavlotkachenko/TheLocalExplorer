import Foundation

struct SpotCollection: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let spots: [Spot]
}

enum CollectionCategory: String, CaseIterable {
    case all = "All Spots"
    case wantToGo = "Want to go"
    case favorites = "Favorites"
    case clientLunch = "Client Lunch"
}
