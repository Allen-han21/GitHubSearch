import Foundation

final class SearchViewModel {

    // MARK: - Output Callbacks

    var onSearchResult: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    var onRecentSearchesUpdated: (() -> Void)?

    // MARK: - Properties

    private let searchRepository: SearchRepositoryProtocol?
    private let recentSearchUseCase: RecentSearchUseCaseProtocol

    private(set) var recentSearches: [RecentSearch] = []

    // MARK: - Initialization

    init(
        searchRepository: SearchRepositoryProtocol? = nil,
        recentSearchUseCase: RecentSearchUseCaseProtocol = RecentSearchUseCase(
            repository: RecentSearchRepository()
        )
    ) {
        self.searchRepository = searchRepository
        self.recentSearchUseCase = recentSearchUseCase
    }

    // MARK: - Input Methods

    func loadRecentSearches() {
        recentSearches = recentSearchUseCase.getRecentSearches()
        onRecentSearchesUpdated?()
    }

    func search(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }

        recentSearchUseCase.saveSearch(trimmedQuery)
        loadRecentSearches()
        onSearchResult?(trimmedQuery)
    }

    func deleteRecentSearch(at index: Int) {
        guard index < recentSearches.count else { return }
        let query = recentSearches[index].query
        recentSearchUseCase.deleteSearch(query)
        loadRecentSearches()
    }

    func deleteAllRecentSearches() {
        recentSearchUseCase.deleteAllSearches()
        loadRecentSearches()
    }

    func recentSearch(at index: Int) -> RecentSearch? {
        guard index < recentSearches.count else { return nil }
        return recentSearches[index]
    }
}
