import Foundation

final class SearchResultViewModel {

    // MARK: - State

    enum State: Equatable {
        case idle
        case loading
        case success(repositories: [Repository], totalCount: Int)
        case empty
        case error(message: String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.empty, .empty):
                return true
            case let (.success(lRepos, lCount), .success(rRepos, rCount)):
                return lRepos.map(\.id) == rRepos.map(\.id) && lCount == rCount
            case let (.error(lMsg), .error(rMsg)):
                return lMsg == rMsg
            default:
                return false
            }
        }
    }

    // MARK: - Output Callbacks

    var onStateChanged: ((State) -> Void)?
    var onPaginationError: ((String) -> Void)?

    // MARK: - Properties

    private let searchUseCase: SearchRepositoriesUseCaseProtocol
    private(set) var state: State = .idle {
        didSet { onStateChanged?(state) }
    }

    private(set) var repositories: [Repository] = []
    private(set) var totalCount: Int = 0
    private var currentPage: Int = 1
    private var hasNextPage: Bool = false
    private var isLoading: Bool = false

    // MARK: - Initialization

    init(searchUseCase: SearchRepositoriesUseCaseProtocol = SearchRepositoriesUseCase(
        repository: SearchRepository()
    )) {
        self.searchUseCase = searchUseCase
    }

    // MARK: - Input Methods

    func search(query: String) {
        guard !isLoading else { return }

        repositories = []
        currentPage = 1
        isLoading = true
        state = .loading

        Task { @MainActor in
            do {
                let result = try await searchUseCase.execute(query: query, page: currentPage)
                self.totalCount = result.totalCount
                self.repositories = result.repositories
                self.hasNextPage = result.hasNextPage

                if result.repositories.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .success(repositories: result.repositories, totalCount: result.totalCount)
                }
            } catch {
                self.state = .error(message: error.localizedDescription)
            }
            self.isLoading = false
        }
    }

    func loadNextPage(query: String) {
        guard !isLoading, hasNextPage else { return }

        isLoading = true
        currentPage += 1

        Task { @MainActor in
            do {
                let result = try await searchUseCase.execute(query: query, page: currentPage)
                self.repositories.append(contentsOf: result.repositories)
                self.hasNextPage = result.hasNextPage
                self.state = .success(repositories: self.repositories, totalCount: self.totalCount)
            } catch {
                self.currentPage -= 1
                print("[Pagination] 다음 페이지 로드 실패: \(error)")
                self.onPaginationError?(error.localizedDescription)
            }
            self.isLoading = false
        }
    }

    func shouldLoadMore(currentIndex: Int) -> Bool {
        !isLoading && hasNextPage && currentIndex >= repositories.count - 5
    }

    func repository(at index: Int) -> Repository? {
        guard index < repositories.count else { return nil }
        return repositories[index]
    }
}
