import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
