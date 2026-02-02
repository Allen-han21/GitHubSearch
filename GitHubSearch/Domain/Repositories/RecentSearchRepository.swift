import Foundation

@MainActor
final class RecentSearchRepository: RecentSearchRepositoryProtocol {

    // MARK: - Properties

    private let storage: RecentSearchStorage

    // MARK: - Initialization

    init(storage: RecentSearchStorage? = nil) {
        self.storage = storage ?? RecentSearchStorage()
    }

    // MARK: - RecentSearchRepositoryProtocol

    func getSearches() -> [RecentSearch] {
        storage.getSearches()
    }

    func saveSearch(_ query: String) {
        storage.saveSearch(query)
    }

    func deleteSearch(_ query: String) {
        storage.deleteSearch(query)
    }

    func deleteAll() {
        storage.deleteAll()
    }
}
