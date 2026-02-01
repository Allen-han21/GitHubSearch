import XCTest
@testable import GitHubSearch

final class SearchViewModelTests: XCTestCase {

    var sut: SearchViewModel!

    override func setUp() {
        super.setUp()
        sut = SearchViewModel()
    }

    override func tearDown() {
        sut = nil
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
}
