import SwiftUI

@MainActor
class TeamPollViewModel: ObservableObject {
    @Published var activePoll: Poll?
    @Published var selectedOptionId: String?
    @Published var isLoading = true
    @Published var isVoting = false
    @Published var errorMessage: String?
    @Published var isShowingCreateSheet = false
    @Published var availableSpots: [Spot] = []
    @Published var selectedSpotIds: Set<String> = []
    @Published var pollTitle = "Lunch today? Pick one."
    @Published var pollDuration = 45

    func loadActivePoll(apiService: APIService) async {
        isLoading = true
        errorMessage = nil
        do {
            let polls = try await apiService.fetchActivePolls()
            activePoll = polls.first
            if let poll = activePoll {
                let maxVotes = poll.options.max(by: { $0.voteCount < $1.voteCount })
                if let winning = maxVotes, winning.voteCount > 0 {
                    selectedOptionId = winning.id
                }
            }
        } catch {
            errorMessage = "Failed to load polls."
        }
        isLoading = false
    }

    func vote(optionId: String, apiService: APIService) async {
        guard let poll = activePoll else { return }
        isVoting = true
        selectedOptionId = optionId
        do {
            let request = VoteRequest(optionId: optionId, voterName: "You")
            activePoll = try await apiService.vote(pollId: poll.id, request: request)
        } catch {
            errorMessage = "Failed to cast vote."
        }
        isVoting = false
    }

    func loadAvailableSpots(apiService: APIService) async {
        do {
            availableSpots = try await apiService.fetchNearbySpots(
                lat: 40.7484, lng: -73.9857, radius: 1.5
            )
        } catch {
            errorMessage = "Failed to load spots."
        }
    }

    func createPoll(apiService: APIService) async {
        guard !selectedSpotIds.isEmpty else { return }
        isLoading = true
        do {
            let request = CreatePollRequest(
                title: pollTitle,
                spotIds: Array(selectedSpotIds),
                durationMinutes: pollDuration
            )
            activePoll = try await apiService.createPoll(request: request)
            isShowingCreateSheet = false
        } catch {
            errorMessage = "Failed to create poll."
        }
        isLoading = false
    }

    func shareToTelegram() {
        guard let poll = activePoll else { return }
        let pollURL = "\(APIService.baseURL)/polls/\(poll.id)"
        let message = "Vote for lunch! Pick one."
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

    var winningOptionId: String? {
        guard let poll = activePoll else { return nil }
        return poll.options.max(by: { $0.voteCount < $1.voteCount })?.id
    }
}
