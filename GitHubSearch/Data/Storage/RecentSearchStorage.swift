import Foundation

final class RecentSearchStorage {

    // MARK: - Constants

    private let key = "recent_searches"
    private let maxCount = 10

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods

    func getSearches() -> [RecentSearch] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }

        do {
            let searches = try JSONDecoder().decode([RecentSearch].self, from: data)
            return searches.sorted { $0.searchedAt > $1.searchedAt }
        } catch {
            return []
        }
    }

    func saveSearch(_ query: String) {
        var searches = getSearches()

        // 중복 제거 (기존 검색어가 있으면 삭제)
        searches.removeAll { $0.query == query }

        // 새 검색어 추가
        let newSearch = RecentSearch(query: query, searchedAt: Date())
        searches.insert(newSearch, at: 0)

        // 최대 개수 제한
        if searches.count > maxCount {
            searches = Array(searches.prefix(maxCount))
        }

        save(searches)
    }

    func deleteSearch(_ query: String) {
        var searches = getSearches()
        searches.removeAll { $0.query == query }
        save(searches)
    }

    func deleteAll() {
        userDefaults.removeObject(forKey: key)
    }

    // MARK: - Private Methods

    private func save(_ searches: [RecentSearch]) {
        do {
            let data = try JSONEncoder().encode(searches)
            userDefaults.set(data, forKey: key)
        } catch {
            // 저장 실패 시 무시
        }
    }
}
