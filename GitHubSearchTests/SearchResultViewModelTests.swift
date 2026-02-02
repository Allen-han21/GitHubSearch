import XCTest
@testable import GitHubSearch

final class SearchResultViewModelTests: XCTestCase {

    // MARK: - Properties

    private var sut: SearchResultViewModel!
    private var mockUseCase: MockSearchRepositoriesUseCase!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockUseCase = MockSearchRepositoriesUseCase()
        sut = SearchResultViewModel(searchUseCase: mockUseCase)
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_초기_상태는_idle이다() {
        XCTAssertEqual(sut.state, .idle)
    }

    func test_검색_시작시_loading_상태가_된다() {
        let expectation = expectation(description: "State changed to loading")

        sut.onStateChanged = { state in
            if case .loading = state {
                expectation.fulfill()
            }
        }

        sut.search(query: "swift")

        wait(for: [expectation], timeout: 1.0)
    }

    func test_검색_성공시_success_상태가_된다() {
        let expectation = expectation(description: "State changed to success")
        mockUseCase.mockResult = SearchResult(
            totalCount: 100,
            repositories: [createMockRepository()],
            hasNextPage: true
        )

        sut.onStateChanged = { state in
            if case .success = state {
                expectation.fulfill()
            }
        }

        sut.search(query: "swift")

        wait(for: [expectation], timeout: 1.0)
    }

    func test_검색_결과가_비어있으면_empty_상태가_된다() {
        let expectation = expectation(description: "State changed to empty")
        mockUseCase.mockResult = SearchResult(
            totalCount: 0,
            repositories: [],
            hasNextPage: false
        )

        sut.onStateChanged = { state in
            if case .empty = state {
                expectation.fulfill()
            }
        }

        sut.search(query: "nonexistent")

        wait(for: [expectation], timeout: 1.0)
    }

    func test_검색_실패시_error_상태가_된다() {
        let expectation = expectation(description: "State changed to error")
        mockUseCase.shouldFail = true

        sut.onStateChanged = { state in
            if case .error = state {
                expectation.fulfill()
            }
        }

        sut.search(query: "swift")

        wait(for: [expectation], timeout: 1.0)
    }

    func test_검색_성공_후_repositories가_채워진다() {
        let expectation = expectation(description: "Repositories populated")
        let mockRepo = createMockRepository()
        mockUseCase.mockResult = SearchResult(
            totalCount: 1,
            repositories: [mockRepo],
            hasNextPage: false
        )

        sut.onStateChanged = { [weak self] state in
            if case .success = state {
                XCTAssertEqual(self?.sut.repositories.count, 1)
                XCTAssertEqual(self?.sut.repositories.first?.id, mockRepo.id)
                expectation.fulfill()
            }
        }

        sut.search(query: "swift")

        wait(for: [expectation], timeout: 1.0)
    }

    func test_repository_at_유효한_인덱스로_호출시_repository를_반환한다() {
        let expectation = expectation(description: "Repository fetched")
        let mockRepo = createMockRepository()
        mockUseCase.mockResult = SearchResult(
            totalCount: 1,
            repositories: [mockRepo],
            hasNextPage: false
        )

        sut.onStateChanged = { [weak self] state in
            if case .success = state {
                let result = self?.sut.repository(at: 0)
                XCTAssertEqual(result?.id, mockRepo.id)
                expectation.fulfill()
            }
        }

        sut.search(query: "swift")

        wait(for: [expectation], timeout: 1.0)
    }

    func test_repository_at_범위_초과_인덱스로_호출시_nil을_반환한다() {
        XCTAssertNil(sut.repository(at: 0))
        XCTAssertNil(sut.repository(at: 100))
    }

    func test_shouldLoadMore_repositories가_비어있으면_false를_반환한다() {
        XCTAssertFalse(sut.shouldLoadMore(currentIndex: 0))
    }

    func test_shouldLoadMore_threshold10_마지막10개이내이고_hasNextPage일때_true반환() async {
        // Given: 30개 repository, hasNextPage = true
        let repos = (0..<30).map { createMockRepository(id: $0) }
        mockUseCase.mockResult = SearchResult(
            totalCount: 100,
            repositories: repos,
            hasNextPage: true
        )

        // When
        sut.search(query: "swift")

        // Wait for async completion
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then: repositories.count = 30, threshold = 10
        // shouldLoadMore = currentIndex >= 30 - 10 = 20
        XCTAssertTrue(sut.shouldLoadMore(currentIndex: 20))
        XCTAssertTrue(sut.shouldLoadMore(currentIndex: 25))
        XCTAssertTrue(sut.shouldLoadMore(currentIndex: 29))
    }

    func test_shouldLoadMore_threshold10_마지막10개밖일때_false반환() async {
        // Given: 30개 repository, hasNextPage = true
        let repos = (0..<30).map { createMockRepository(id: $0) }
        mockUseCase.mockResult = SearchResult(
            totalCount: 100,
            repositories: repos,
            hasNextPage: true
        )

        // When
        sut.search(query: "swift")

        // Wait for async completion
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then: shouldLoadMore = currentIndex >= 30 - 10 = 20
        XCTAssertFalse(sut.shouldLoadMore(currentIndex: 19))
        XCTAssertFalse(sut.shouldLoadMore(currentIndex: 10))
        XCTAssertFalse(sut.shouldLoadMore(currentIndex: 0))
    }

    func test_loadNextPage_호출시_loadingMore상태로변경() async {
        // Given
        let repos = (0..<30).map { createMockRepository(id: $0) }
        mockUseCase.mockResult = SearchResult(
            totalCount: 100,
            repositories: repos,
            hasNextPage: true
        )

        var stateHistory: [SearchResultViewModel.State] = []
        sut.onStateChanged = { state in
            stateHistory.append(state)
        }

        // When - initial search
        sut.search(query: "swift")
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Add delay for loadNextPage
        mockUseCase.delay = 0.05
        sut.loadNextPage(query: "swift")

        // Wait briefly to capture loadingMore state
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Then - verify loadingMore state was reached
        XCTAssertTrue(stateHistory.contains(.loadingMore))

        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    func test_검색_중_중복_검색_요청은_무시된다() {
        let expectation = expectation(description: "Only one search")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        mockUseCase.delay = 0.1
        mockUseCase.mockResult = SearchResult(
            totalCount: 1,
            repositories: [createMockRepository()],
            hasNextPage: false
        )

        sut.onStateChanged = { state in
            if case .success = state {
                expectation.fulfill()
            }
        }

        sut.search(query: "swift")
        sut.search(query: "swift")

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helper

    private func createMockRepository(id: Int = 1) -> Repository {
        Repository(
            id: id,
            name: "TestRepo\(id)",
            ownerName: "TestOwner",
            avatarUrl: "https://example.com/avatar.png",
            description: "Test Description",
            htmlUrl: "https://github.com/TestOwner/TestRepo\(id)",
            starCount: 100,
            language: "Swift"
        )
    }
}

// MARK: - Mock

final class MockSearchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol {
    var mockResult: SearchResult?
    var shouldFail = false
    var delay: TimeInterval = 0

    func execute(query: String, page: Int) async throws -> SearchResult {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        if shouldFail {
            throw NSError(domain: "Test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        return mockResult ?? SearchResult(totalCount: 0, repositories: [], hasNextPage: false)
    }
}
