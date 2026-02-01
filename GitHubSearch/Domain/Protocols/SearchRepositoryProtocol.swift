import Foundation

protocol SearchRepositoryProtocol {
    func searchRepositories(query: String, page: Int) async throws -> SearchResult
}
