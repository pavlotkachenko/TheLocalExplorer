import Foundation

struct Poll: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let options: [PollOption]
    let totalVotes: Int
    let closesAt: String
    let createdAt: String
    let voters: [Voter]

    enum CodingKeys: String, CodingKey {
        case id, title, options
        case totalVotes = "total_votes"
        case closesAt = "closes_at"
        case createdAt = "created_at"
        case voters
    }

    var minutesRemaining: Int {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let closeDate = formatter.date(from: closesAt) else { return 0 }
        let remaining = closeDate.timeIntervalSince(Date())
        return max(0, Int(remaining / 60))
    }
}

struct PollOption: Codable, Identifiable, Hashable {
    let id: String
    let spotId: String
    let spotName: String
    let spotImageURL: String
    let walkingTimeMinutes: Int
    let voteCount: Int
    let votePercentage: Double

    enum CodingKeys: String, CodingKey {
        case id
        case spotId = "spot_id"
        case spotName = "spot_name"
        case spotImageURL = "spot_image_url"
        case walkingTimeMinutes = "walking_time_minutes"
        case voteCount = "vote_count"
        case votePercentage = "vote_percentage"
    }
}

struct Voter: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case avatarURL = "avatar_url"
    }
}

struct CreatePollRequest: Codable {
    let title: String
    let spotIds: [String]
    let durationMinutes: Int

    enum CodingKeys: String, CodingKey {
        case title
        case spotIds = "spot_ids"
        case durationMinutes = "duration_minutes"
    }
}

struct VoteRequest: Codable {
    let optionId: String
    let voterName: String

    enum CodingKeys: String, CodingKey {
        case optionId = "option_id"
        case voterName = "voter_name"
    }
}
