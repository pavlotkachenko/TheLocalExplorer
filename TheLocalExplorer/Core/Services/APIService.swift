import Foundation
import SwiftUI

@MainActor
class APIService: ObservableObject {
    // MARK: - Configuration
    // Change this URL to point to your deployed backend instance.
    // To run locally: cd backend && poetry install && poetry run uvicorn app.main:app --port 8001
    // Then set baseURL to "http://localhost:8001"
    static let baseURL = "http://localhost:8001"

    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    // MARK: - Daily Drops

    func fetchTodayDrops(lat: Double = 40.7484, lng: Double = -73.9857) async throws -> DailyDropResponse {
        let url = URL(string: "\(Self.baseURL)/api/v1/drops/today?lat=\(lat)&lng=\(lng)")!
        return try await fetch(url: url)
    }

    // MARK: - Spots

    func fetchNearbySpots(lat: Double, lng: Double, radius: Double = 1.0) async throws -> [Spot] {
        let url = URL(string: "\(Self.baseURL)/api/v1/spots/nearby?lat=\(lat)&lng=\(lng)&radius=\(radius)")!
        return try await fetch(url: url)
    }

    func fetchSpot(id: String) async throws -> Spot {
        let url = URL(string: "\(Self.baseURL)/api/v1/spots/\(id)")!
        return try await fetch(url: url)
    }

    func searchSpots(query: String? = nil, cuisine: String? = nil, price: Int? = nil, vibe: String? = nil) async throws -> [Spot] {
        var components = URLComponents(string: "\(Self.baseURL)/api/v1/spots/search")!
        var queryItems: [URLQueryItem] = []
        if let query { queryItems.append(URLQueryItem(name: "q", value: query)) }
        if let cuisine { queryItems.append(URLQueryItem(name: "cuisine", value: cuisine)) }
        if let price { queryItems.append(URLQueryItem(name: "price", value: String(price))) }
        if let vibe { queryItems.append(URLQueryItem(name: "vibe", value: vibe)) }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return try await fetch(url: components.url!)
    }

    // MARK: - Polls

    func createPoll(request: CreatePollRequest) async throws -> Poll {
        let url = URL(string: "\(Self.baseURL)/api/v1/polls")!
        return try await post(url: url, body: request)
    }

    func fetchPoll(id: String) async throws -> Poll {
        let url = URL(string: "\(Self.baseURL)/api/v1/polls/\(id)")!
        return try await fetch(url: url)
    }

    func vote(pollId: String, request: VoteRequest) async throws -> Poll {
        let url = URL(string: "\(Self.baseURL)/api/v1/polls/\(pollId)/vote")!
        return try await post(url: url, body: request)
    }

    func fetchActivePolls() async throws -> [Poll] {
        let url = URL(string: "\(Self.baseURL)/api/v1/polls")!
        return try await fetch(url: url)
    }

    // MARK: - Collections

    func fetchCollections() async throws -> [SpotCollection] {
        let url = URL(string: "\(Self.baseURL)/api/v1/collections")!
        return try await fetch(url: url)
    }

    func saveSpot(spotId: String, collectionName: String) async throws {
        let url = URL(string: "\(Self.baseURL)/api/v1/collections/\(collectionName)/spots")!
        let body = ["spot_id": spotId]
        let _: [String: String] = try await post(url: url, body: body)
    }

    func removeSpot(spotId: String, collectionName: String) async throws {
        let url = URL(string: "\(Self.baseURL)/api/v1/collections/\(collectionName)/spots/\(spotId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
    }

    // MARK: - Private

    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        return try decoder.decode(T.self, from: data)
    }

    private func post<T: Decodable, B: Encodable>(url: URL, body: B) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        return try decoder.decode(T.self, from: data)
    }
}

enum APIError: Error, LocalizedError {
    case requestFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed: return "Request failed. Please try again."
        case .decodingFailed: return "Failed to process response."
        }
    }
}
