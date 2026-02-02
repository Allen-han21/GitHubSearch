import Foundation

protocol RecentSearchUseCaseProtocol {
    func getRecentSearches() -> [RecentSearch]
    func saveSearch(_ query: String)
    func deleteSearch(_ query: String)
    func deleteAllSearches()
    func getAutocompleteSuggestions(for query: String) -> [RecentSearch]
}

final class RecentSearchUseCase: RecentSearchUseCaseProtocol {

    // MARK: - Properties

    private let repository: RecentSearchRepositoryProtocol

    // MARK: - Initialization

    init(repository: RecentSearchRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - RecentSearchUseCaseProtocol

    func getRecentSearches() -> [RecentSearch] {
        repository.getSearches()
    }

    func saveSearch(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }
        repository.saveSearch(trimmedQuery)
    }

    func deleteSearch(_ query: String) {
        repository.deleteSearch(query)
    }

    func deleteAllSearches() {
        repository.deleteAll()
    }

    func getAutocompleteSuggestions(for query: String) -> [RecentSearch] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return repository.getSearches()
            .filter { $0.query.lowercased().contains(lowercasedQuery) }
    }
}
