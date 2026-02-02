import XCTest
@testable import GitHubSearch

final class RecentSearchUseCaseTests: XCTestCase {

    var sut: RecentSearchUseCase!
    var mockRepository: MockRecentSearchRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockRecentSearchRepository()
        sut = RecentSearchUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - getAutocompleteSuggestions 테스트

    func test_getAutocompleteSuggestions_빈쿼리_빈배열반환() {
        // given
        mockRepository.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date())
        ]

        // when
        let result = sut.getAutocompleteSuggestions(for: "")

        // then
        XCTAssertTrue(result.isEmpty)
    }

    func test_getAutocompleteSuggestions_매칭없음_빈배열반환() {
        // given
        mockRepository.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date()),
            RecentSearch(query: "kotlin", searchedAt: Date())
        ]

        // when
        let result = sut.getAutocompleteSuggestions(for: "java")

        // then
        XCTAssertTrue(result.isEmpty)
    }

    func test_getAutocompleteSuggestions_매칭있음_필터링된결과() {
        // given
        mockRepository.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date()),
            RecentSearch(query: "swiftui", searchedAt: Date()),
            RecentSearch(query: "kotlin", searchedAt: Date())
        ]

        // when
        let result = sut.getAutocompleteSuggestions(for: "sw")

        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.query == "swift" })
        XCTAssertTrue(result.contains { $0.query == "swiftui" })
    }

    func test_getAutocompleteSuggestions_대소문자무시() {
        // given
        mockRepository.mockSearches = [
            RecentSearch(query: "Swift", searchedAt: Date())
        ]

        // when
        let result = sut.getAutocompleteSuggestions(for: "SWIFT")

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.query, "Swift")
    }

    func test_getAutocompleteSuggestions_부분매칭() {
        // given
        mockRepository.mockSearches = [
            RecentSearch(query: "alamofire", searchedAt: Date())
        ]

        // when
        let result = sut.getAutocompleteSuggestions(for: "fire")

        // then
        XCTAssertEqual(result.count, 1)
    }
}

// MARK: - Mock

final class MockRecentSearchRepository: RecentSearchRepositoryProtocol {

    var mockSearches: [RecentSearch] = []

    func getSearches() -> [RecentSearch] {
        return mockSearches
    }

    func saveSearch(_ query: String) {
        let search = RecentSearch(query: query, searchedAt: Date())
        mockSearches.insert(search, at: 0)
    }

    func deleteSearch(_ query: String) {
        mockSearches.removeAll { $0.query == query }
    }

    func deleteAll() {
        mockSearches.removeAll()
    }
}
