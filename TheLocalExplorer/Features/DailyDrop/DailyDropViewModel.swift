import SwiftUI

@MainActor
class DailyDropViewModel: ObservableObject {
    @Published var dailyDrop: DailyDropResponse?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var selectedVibe: String? = nil

    let vibeFilters = ["Outdoor Seating", "Power Lunch", "Cheap Eats", "Quiet"]

    func loadDrops(apiService: APIService, lat: Double, lng: Double) async {
        isLoading = true
        errorMessage = nil
        do {
            dailyDrop = try await apiService.fetchTodayDrops(lat: lat, lng: lng)
        } catch {
            errorMessage = "Looks like we missed breakfast. Pull to refresh today's drops."
        }
        isLoading = false
    }

    func selectVibe(_ vibe: String) {
        if selectedVibe == vibe {
            selectedVibe = nil
        } else {
            selectedVibe = vibe
        }
    }

    var filteredNearbySpots: [Spot] {
        guard let spots = dailyDrop?.nearbySpots else { return [] }
        guard let vibe = selectedVibe else { return spots }
        return spots.filter { spot in
            spot.vibes.contains { $0.localizedCaseInsensitiveContains(vibe) }
        }
    }
}
