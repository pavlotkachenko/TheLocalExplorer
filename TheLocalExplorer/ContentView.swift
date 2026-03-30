import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .dailyDrop
    @State private var navigationPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $navigationPath) {
                DailyDropView()
                    .navigationDestination(for: Spot.self) { spot in
                        SpotProfileView(spot: spot)
                    }
            }
            .tabItem {
                Label("Home", systemImage: selectedTab == .dailyDrop ? "house.fill" : "house")
            }
            .tag(AppTab.dailyDrop)

            NavigationStack {
                RadarMapView()
                    .navigationDestination(for: Spot.self) { spot in
                        SpotProfileView(spot: spot)
                    }
            }
            .tabItem {
                Label("Radar Map", systemImage: selectedTab == .radarMap ? "map.fill" : "map")
            }
            .tag(AppTab.radarMap)

            NavigationStack {
                SavedListView()
                    .navigationDestination(for: Spot.self) { spot in
                        SpotProfileView(spot: spot)
                    }
            }
            .tabItem {
                Label("Saved", systemImage: selectedTab == .saved ? "bookmark.fill" : "bookmark")
            }
            .tag(AppTab.saved)

            NavigationStack {
                TeamPollView()
            }
            .tabItem {
                Label("Team Poll", systemImage: selectedTab == .teamPoll ? "person.3.fill" : "person.3")
            }
            .tag(AppTab.teamPoll)
        }
        .tint(AppColors.tomatoRed)
    }
}

enum AppTab: Hashable {
    case dailyDrop
    case radarMap
    case saved
    case teamPoll
}
