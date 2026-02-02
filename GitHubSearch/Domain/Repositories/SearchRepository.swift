import Foundation

final class SearchRepository: SearchRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let perPage: Int

    init(networkService: NetworkServiceProtocol = NetworkService(), perPage: Int = 30) {
        self.networkService = networkService
        self.perPage = perPage
    }

    func searchRepositories(query: String, page: Int) async throws -> SearchResult {
        let endpoint = Endpoint.searchRepositories(query: query, page: page, perPage: perPage)
        let response: SearchResponseDTO = try await networkService.request(endpoint)
        return response.toEntity(currentPage: page, perPage: perPage)
    }
}
