import XCTest
@testable import GitHubSearch

final class RecentSearchStorageTests: XCTestCase {

    var sut: RecentSearchStorage!
    var testUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testUserDefaults = UserDefaults(suiteName: "TestUserDefaults")!
        testUserDefaults.removePersistentDomain(forName: "TestUserDefaults")
        sut = RecentSearchStorage(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "TestUserDefaults")
        testUserDefaults = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - 저장 테스트

    func test_검색어를_저장하면_조회할_수_있다() {
        // when
        sut.saveSearch("swift")

        // then
        let searches = sut.getSearches()
        XCTAssertEqual(searches.count, 1)
        XCTAssertEqual(searches.first?.query, "swift")
    }

    func test_여러_검색어를_저장하면_최신순으로_정렬된다() {
        // when
        sut.saveSearch("swift")
        sut.saveSearch("kotlin")
        sut.saveSearch("java")

        // then
        let searches = sut.getSearches()
        XCTAssertEqual(searches.count, 3)
        XCTAssertEqual(searches[0].query, "java")
        XCTAssertEqual(searches[1].query, "kotlin")
        XCTAssertEqual(searches[2].query, "swift")
    }

    // MARK: - 중복 제거 테스트

    func test_동일한_검색어를_저장하면_기존_항목이_제거되고_최신으로_갱신된다() {
        // given
        sut.saveSearch("swift")
        sut.saveSearch("kotlin")

        // when
        sut.saveSearch("swift")

        // then
        let searches = sut.getSearches()
        XCTAssertEqual(searches.count, 2)
        XCTAssertEqual(searches[0].query, "swift")
        XCTAssertEqual(searches[1].query, "kotlin")
    }

    // MARK: - 최대 개수 제한 테스트

    func test_최대_10개까지만_저장된다() {
        // given
        for i in 1...15 {
            sut.saveSearch("query\(i)")
        }

        // then
        let searches = sut.getSearches()
        XCTAssertEqual(searches.count, 10)
        XCTAssertEqual(searches.first?.query, "query15")
        XCTAssertEqual(searches.last?.query, "query6")
    }

    // MARK: - 삭제 테스트

    func test_특정_검색어를_삭제할_수_있다() {
        // given
        sut.saveSearch("swift")
        sut.saveSearch("kotlin")
        sut.saveSearch("java")

        // when
        sut.deleteSearch("kotlin")

        // then
        let searches = sut.getSearches()
        XCTAssertEqual(searches.count, 2)
        XCTAssertFalse(searches.contains { $0.query == "kotlin" })
    }

    func test_전체_삭제하면_모든_검색어가_삭제된다() {
        // given
        sut.saveSearch("swift")
        sut.saveSearch("kotlin")
        sut.saveSearch("java")

        // when
        sut.deleteAll()

        // then
        let searches = sut.getSearches()
        XCTAssertTrue(searches.isEmpty)
    }

    // MARK: - 빈 상태 테스트

    func test_저장된_검색어가_없으면_빈_배열을_반환한다() {
        // then
        let searches = sut.getSearches()
        XCTAssertTrue(searches.isEmpty)
    }

    func test_존재하지_않는_검색어를_삭제해도_에러가_발생하지_않는다() {
        // given
        sut.saveSearch("swift")

        // when & then - 에러 없이 실행
        sut.deleteSearch("nonexistent")

        let searches = sut.getSearches()
        XCTAssertEqual(searches.count, 1)
    }
}
