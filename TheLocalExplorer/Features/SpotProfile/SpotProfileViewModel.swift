import SwiftUI

@MainActor
class SpotProfileViewModel: ObservableObject {
    @Published var spot: Spot
    @Published var isShowingLightbox = false
    @Published var selectedPhotoIndex = 0
    @Published var isShowingPollSheet = false
    @Published var selectedPollSpots: [Spot] = []
    @Published var isSaved = false

    init(spot: Spot) {
        self.spot = spot
    }

    func openDirections() {
        let urlString = "maps://?daddr=\(spot.latitude),\(spot.longitude)&dirflg=w"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    func toggleSave(apiService: APIService) async {
        isSaved.toggle()
        if isSaved {
            try? await apiService.saveSpot(spotId: spot.id, collectionName: "favorites")
        } else {
            try? await apiService.removeSpot(spotId: spot.id, collectionName: "favorites")
        }
    }

    func shareToTelegram(pollId: String) {
        let pollURL = "\(APIService.baseURL)/polls/\(pollId)"
        let message = "Vote for lunch! 🍽"
        let telegramURL = "tg://msg_url?url=\(pollURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: telegramURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let webURL = "https://t.me/share/url?url=\(pollURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            if let url = URL(string: webURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}
