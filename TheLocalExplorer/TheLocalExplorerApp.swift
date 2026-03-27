import SwiftUI

@main
struct TheLocalExplorerApp: App {
    @StateObject private var locationService = LocationService()
    @StateObject private var apiService = APIService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationService)
                .environmentObject(apiService)
        }
    }
}
