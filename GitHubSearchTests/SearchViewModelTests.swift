import XCTest
@testable import GitHubSearch

final class SearchViewModelTests: XCTestCase {

    var sut: SearchViewModel!
    var mockRecentSearchUseCase: MockRecentSearchUseCase!

    override func setUp() {
        super.setUp()
        mockRecentSearchUseCase = MockRecentSearchUseCase()
        sut = SearchViewModel(recentSearchUseCase: mockRecentSearchUseCase)
    }

    override func tearDown() {
        sut = nil
        mockRecentSearchUseCase = nil
        super.tearDown()
    }

    // MARK: - 빈 문자열 테스트

    func test_검색어가_빈문자열이면_콜백이_호출되지_않는다() {
        // given
        var callbackCalled = false
        sut.onSearchResult = { _ in
            callbackCalled = true
        }

        // when
        sut.search(query: "")

        // then
        XCTAssertFalse(callbackCalled, "빈 문자열로 검색 시 콜백이 호출되면 안 됨")
    }

    // MARK: - 공백 문자열 테스트

    func test_검색어가_공백만_있으면_콜백이_호출되지_않는다() {
        // given
        var callbackCalled = false
        sut.onSearchResult = { _ in
            callbackCalled = true
        }

        // when
        sut.search(query: "   ")

        // then
        XCTAssertFalse(callbackCalled, "공백만 있는 검색어로 검색 시 콜백이 호출되면 안 됨")
    }

    func test_검색어가_탭과_공백만_있으면_콜백이_호출되지_않는다() {
        // given
        var callbackCalled = false
        sut.onSearchResult = { _ in
            callbackCalled = true
        }

        // when
        sut.search(query: "\t  \t")

        // then
        XCTAssertFalse(callbackCalled, "탭과 공백만 있는 검색어로 검색 시 콜백이 호출되면 안 됨")
    }

    // MARK: - 정상 검색 콜백 테스트

    func test_유효한_검색어로_검색하면_onSearchResult_콜백이_호출된다() {
        // given
        let expectation = XCTestExpectation(description: "onSearchResult 콜백 호출")
        var receivedQuery: String?

        sut.onSearchResult = { query in
            receivedQuery = query
            expectation.fulfill()
        }

        // when
        sut.search(query: "swift")

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedQuery, "swift")
    }

    func test_검색어_앞뒤_공백이_제거되어_콜백에_전달된다() {
        // given
        let expectation = XCTestExpectation(description: "트림된 검색어 전달")
        var receivedQuery: String?

        sut.onSearchResult = { query in
            receivedQuery = query
            expectation.fulfill()
        }

        // when
        sut.search(query: "  swift  ")

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedQuery, "swift", "앞뒤 공백이 제거된 검색어가 전달되어야 함")
    }

    func test_한글_검색어도_정상적으로_콜백이_호출된다() {
        // given
        let expectation = XCTestExpectation(description: "한글 검색어 콜백 호출")
        var receivedQuery: String?

        sut.onSearchResult = { query in
            receivedQuery = query
            expectation.fulfill()
        }

        // when
        sut.search(query: "스위프트")

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedQuery, "스위프트")
    }

    // MARK: - 콜백 미설정 테스트

    func test_onSearchResult_콜백이_nil이어도_크래시가_발생하지_않는다() {
        // given
        sut.onSearchResult = nil

        // when & then - 크래시 없이 실행되면 성공
        sut.search(query: "swift")
    }

    // MARK: - 최근 검색어 테스트

    func test_검색하면_최근_검색어에_저장된다() {
        // given
        sut.onSearchResult = { _ in }

        // when
        sut.search(query: "swift")

        // then
        XCTAssertTrue(mockRecentSearchUseCase.saveSearchCalled)
        XCTAssertEqual(mockRecentSearchUseCase.savedQuery, "swift")
    }

    func test_loadRecentSearches_호출시_최근검색어가_로드된다() {
        // given
        mockRecentSearchUseCase.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date()),
            RecentSearch(query: "kotlin", searchedAt: Date())
        ]

        // when
        sut.loadRecentSearches()

        // then
        XCTAssertEqual(sut.recentSearches.count, 2)
        XCTAssertEqual(sut.recentSearches[0].query, "swift")
    }

    func test_loadRecentSearches_호출시_콜백이_호출된다() {
        // given
        var callbackCalled = false
        sut.onRecentSearchesUpdated = {
            callbackCalled = true
        }

        // when
        sut.loadRecentSearches()

        // then
        XCTAssertTrue(callbackCalled)
    }

    func test_deleteRecentSearch_호출시_해당_검색어가_삭제된다() {
        // given
        mockRecentSearchUseCase.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date()),
            RecentSearch(query: "kotlin", searchedAt: Date())
        ]
        sut.loadRecentSearches()

        // when
        sut.deleteRecentSearch(at: 0)

        // then
        XCTAssertTrue(mockRecentSearchUseCase.deleteSearchCalled)
        XCTAssertEqual(mockRecentSearchUseCase.deletedQuery, "swift")
    }

    func test_deleteAllRecentSearches_호출시_모든_검색어가_삭제된다() {
        // given
        mockRecentSearchUseCase.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date()),
            RecentSearch(query: "kotlin", searchedAt: Date())
        ]
        sut.loadRecentSearches()

        // when
        sut.deleteAllRecentSearches()

        // then
        XCTAssertTrue(mockRecentSearchUseCase.deleteAllCalled)
    }

    func test_recentSearch_at_유효한_인덱스로_호출시_검색어를_반환한다() {
        // given
        mockRecentSearchUseCase.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date())
        ]
        sut.loadRecentSearches()

        // when
        let result = sut.recentSearch(at: 0)

        // then
        XCTAssertEqual(result?.query, "swift")
    }

    func test_recentSearch_at_범위초과_인덱스로_호출시_nil을_반환한다() {
        // given
        sut.loadRecentSearches()

        // when
        let result = sut.recentSearch(at: 100)

        // then
        XCTAssertNil(result)
    }

    // MARK: - 자동완성 테스트

    func test_updateAutocomplete_검색중이고_입력있으면_isSearching이_true() {
        // when
        sut.updateAutocomplete(query: "swift", isActive: true)

        // then
        XCTAssertTrue(sut.isSearching)
    }

    func test_updateAutocomplete_검색중이지만_입력없으면_isSearching이_false() {
        // when
        sut.updateAutocomplete(query: "", isActive: true)

        // then
        XCTAssertFalse(sut.isSearching)
    }

    func test_updateAutocomplete_검색중이_아니면_isSearching이_false() {
        // when
        sut.updateAutocomplete(query: "swift", isActive: false)

        // then
        XCTAssertFalse(sut.isSearching)
    }

    func test_updateAutocomplete_검색중이면_자동완성목록이_업데이트된다() {
        // given
        mockRecentSearchUseCase.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date()),
            RecentSearch(query: "swiftui", searchedAt: Date()),
            RecentSearch(query: "kotlin", searchedAt: Date())
        ]

        // when
        sut.updateAutocomplete(query: "sw", isActive: true)

        // then
        XCTAssertEqual(sut.autocompleteSuggestions.count, 2)
    }

    func test_updateAutocomplete_검색중이_아니면_자동완성목록이_비워진다() {
        // given
        mockRecentSearchUseCase.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date())
        ]
        sut.updateAutocomplete(query: "sw", isActive: true)
        XCTAssertFalse(sut.autocompleteSuggestions.isEmpty)

        // when
        sut.updateAutocomplete(query: "sw", isActive: false)

        // then
        XCTAssertTrue(sut.autocompleteSuggestions.isEmpty)
    }

    func test_updateAutocomplete_호출시_콜백이_호출된다() {
        // given
        var callbackCalled = false
        sut.onRecentSearchesUpdated = {
            callbackCalled = true
        }

        // when
        sut.updateAutocomplete(query: "test", isActive: true)

        // then
        XCTAssertTrue(callbackCalled)
    }

    func test_autocompleteSuggestion_at_유효한_인덱스로_호출시_항목을_반환한다() {
        // given
        mockRecentSearchUseCase.mockSearches = [
            RecentSearch(query: "swift", searchedAt: Date())
        ]
        sut.updateAutocomplete(query: "sw", isActive: true)

        // when
        let result = sut.autocompleteSuggestion(at: 0)

        // then
        XCTAssertEqual(result?.query, "swift")
    }

    func test_autocompleteSuggestion_at_범위초과_인덱스로_호출시_nil을_반환한다() {
        // when
        let result = sut.autocompleteSuggestion(at: 100)

        // then
        XCTAssertNil(result)
    }
}

// MARK: - Mock

final class MockRecentSearchUseCase: RecentSearchUseCaseProtocol {

    var mockSearches: [RecentSearch] = []

    var saveSearchCalled = false
    var savedQuery: String?

    var deleteSearchCalled = false
    var deletedQuery: String?

    var deleteAllCalled = false

    func getRecentSearches() -> [RecentSearch] {
        return mockSearches
    }

    func saveSearch(_ query: String) {
        saveSearchCalled = true
        savedQuery = query
    }

    func deleteSearch(_ query: String) {
        deleteSearchCalled = true
        deletedQuery = query
        mockSearches.removeAll { $0.query == query }
    }

    func deleteAllSearches() {
        deleteAllCalled = true
        mockSearches.removeAll()
    }

    func getAutocompleteSuggestions(for query: String) -> [RecentSearch] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return mockSearches.filter { $0.query.lowercased().contains(lowercasedQuery) }
    }
}
