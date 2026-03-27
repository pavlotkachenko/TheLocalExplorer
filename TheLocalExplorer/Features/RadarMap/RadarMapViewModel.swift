import SwiftUI
import CoreLocation

@MainActor
class RadarMapViewModel: ObservableObject {
    @Published var spots: [Spot] = []
    @Published var selectedSpot: Spot?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: MapFilter?
    @Published var isDrawMode = false
    @Published var showMiniCard = false

    enum MapFilter: String, CaseIterable {
        case fiveMin = "< 5 min"
        case price = "Price"
        case cuisine = "Cuisine"
        case waitTime = "Wait Time"
    }

    func loadSpots(apiService: APIService, lat: Double, lng: Double) async {
        isLoading = true
        do {
            spots = try await apiService.fetchNearbySpots(lat: lat, lng: lng, radius: 2.0)
        } catch {
            errorMessage = "Failed to load nearby spots."
        }
        isLoading = false
    }

    func selectSpot(_ spot: Spot) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedSpot = spot
            showMiniCard = true
        }
    }

    func dismissMiniCard() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showMiniCard = false
            selectedSpot = nil
        }
    }

    func toggleFilter(_ filter: MapFilter) {
        if selectedFilter == filter {
            selectedFilter = nil
        } else {
            selectedFilter = filter
        }
    }

    var filteredSpots: [Spot] {
        var result = spots

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.cuisine.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let filter = selectedFilter {
            switch filter {
            case .fiveMin:
                result = result.filter { $0.walkingTimeMinutes <= 5 }
            case .price:
                result = result.sorted { $0.priceLevel < $1.priceLevel }
            case .cuisine:
                result = result.sorted { $0.cuisine < $1.cuisine }
            case .waitTime:
                result = result.sorted { $0.walkingTimeMinutes < $1.walkingTimeMinutes }
            }
        }

        return result
    }
}
