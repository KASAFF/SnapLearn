import Foundation
import Combine
import SwiftUI
import Kingfisher

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.unsplash.com/search/photos"
    private let accessKey = "4w5CFGQ_Ub5RkUrnp6C1pVtOtBesTU4zTux0hdxZzwE"

    func fetchImageURL(for query: String) -> AnyPublisher<String?, Never> {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return Just(nil).eraseToAnyPublisher()
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "per_page", value: "1")
        ]

        guard let url = urlComponents.url else {
            return Just(nil).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: UnsplashSearchResult.self, decoder: JSONDecoder())
            .map { $0.results.first?.urls.regular }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
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


class UnsplashImageFetcher: ObservableObject {
    @Published var imageURL: String?

    private var cancellable: AnyCancellable?

    func fetchImage(for word: String) {
        cancellable = NetworkManager.shared.fetchImageURL(for: word)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .assign(to: \.imageURL, on: self)
    }
}
