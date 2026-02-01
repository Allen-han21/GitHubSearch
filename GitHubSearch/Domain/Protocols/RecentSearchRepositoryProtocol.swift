import Foundation

protocol RecentSearchRepositoryProtocol {
    func getSearches() -> [RecentSearch]
    func saveSearch(_ query: String)
    func deleteSearch(_ query: String)
    func deleteAll()
}
