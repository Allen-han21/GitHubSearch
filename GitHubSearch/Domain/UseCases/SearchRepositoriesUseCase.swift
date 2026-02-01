import Foundation

protocol SearchRepositoriesUseCaseProtocol {
    func execute(query: String, page: Int) async throws -> SearchResult
}

final class SearchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol {

    // MARK: - Properties

    private let repository: SearchRepositoryProtocol

    // MARK: - Initialization

    init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - SearchRepositoriesUseCaseProtocol

    func execute(query: String, page: Int) async throws -> SearchResult {
        try await repository.searchRepositories(query: query, page: page)
    }
}
