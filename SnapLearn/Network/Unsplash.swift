import Foundation
import Combine
import SwiftUI
import Kingfisher

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.unsplash.com/search/photos"
    private let accessKey = "4w5CFGQ_Ub5RkUrnp6C1pVtOtBesTU4zTux0hdxZzwE"

    func fetchImageURL(for query: String) async throws -> String? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "per_page", value: "1")
        ]

        guard let url = urlComponents.url else {
            return nil
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResult = try JSONDecoder().decode(UnsplashSearchResult.self, from: data)
        return searchResult.results.first?.urls.regular
    }
}

struct UnsplashSearchResult: Decodable {
    let results: [UnsplashImage]
}

struct UnsplashImage: Decodable {
    let urls: URLS

    struct URLS: Decodable {
        let regular: String
    }
}

final class UnsplashImageFetcher: ObservableObject {

    func fetchImage(for word: String) async -> String? {
        do {
            let url = try await NetworkManager.shared.fetchImageURL(for: word)
            return url
        } catch {
            print("Failed to fetch image URL: \(error)")
            return nil
        }
    }
    
}

