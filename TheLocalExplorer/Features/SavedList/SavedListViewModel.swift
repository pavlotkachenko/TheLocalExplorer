import SwiftUI

@MainActor
class SavedListViewModel: ObservableObject {
    @Published var collections: [SpotCollection] = []
    @Published var selectedCategory: CollectionCategory = .all
    @Published var isLoading = true
    @Published var errorMessage: String?

    var displayedSpots: [Spot] {
        switch selectedCategory {
        case .all:
            return collections.flatMap(\.spots)
        case .wantToGo:
            return collections.first(where: { $0.name == "want_to_go" })?.spots ?? []
        case .favorites:
            return collections.first(where: { $0.name == "favorites" })?.spots ?? []
        case .clientLunch:
            return collections.first(where: { $0.name == "client_lunch" })?.spots ?? []
        }
    }

    func loadCollections(apiService: APIService) async {
        isLoading = true
        errorMessage = nil
        do {
            collections = try await apiService.fetchCollections()
        } catch {
            errorMessage = "Failed to load saved spots."
        }
        isLoading = false
    }

    func deleteSpot(spot: Spot, apiService: APIService) async {
        let collectionName = selectedCategory == .all ? "favorites" : selectedCategory.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
        try? await apiService.removeSpot(spotId: spot.id, collectionName: collectionName)
        await loadCollections(apiService: apiService)
    }
}
