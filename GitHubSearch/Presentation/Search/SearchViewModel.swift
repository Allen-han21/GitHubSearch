import Foundation

final class SearchViewModel {

    // MARK: - Output Callbacks

    var onSearchResult: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - Properties

    private let searchRepository: SearchRepositoryProtocol?

    // MARK: - Initialization

    init(searchRepository: SearchRepositoryProtocol? = nil) {
        self.searchRepository = searchRepository
    }

    // MARK: - Input Methods

    func search(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }

        // Issue #5에서 최근 검색어 저장 로직 추가 예정
        onSearchResult?(trimmedQuery)
    }
}
