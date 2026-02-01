import XCTest
@testable import GitHubSearch

final class SearchViewControllerTests: XCTestCase {

    var sut: SearchViewController!

    override func setUp() {
        super.setUp()
        // 테스트 전 최근 검색어 초기화
        UserDefaults.standard.removeObject(forKey: "recent_searches")
        sut = SearchViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - View 존재 테스트

    func test_뷰가_로드되면_tableView가_존재한다() {
        // given & when
        let tableView = sut.view.subviews.first { $0 is UITableView }

        // then
        XCTAssertNotNil(tableView, "SearchViewController에 tableView가 존재해야 함")
    }

    func test_tableView가_올바른_delegate를_가진다() {
        // given
        let tableView = sut.view.subviews.compactMap { $0 as? UITableView }.first

        // then
        XCTAssertNotNil(tableView?.delegate, "tableView의 delegate가 설정되어야 함")
        XCTAssertTrue(tableView?.delegate === sut, "tableView의 delegate는 SearchViewController여야 함")
    }

    func test_tableView가_올바른_dataSource를_가진다() {
        // given
        let tableView = sut.view.subviews.compactMap { $0 as? UITableView }.first

        // then
        XCTAssertNotNil(tableView?.dataSource, "tableView의 dataSource가 설정되어야 함")
        XCTAssertTrue(tableView?.dataSource === sut, "tableView의 dataSource는 SearchViewController여야 함")
    }

    // MARK: - SearchController 테스트

    func test_navigationItem에_searchController가_설정되어_있다() {
        // then
        XCTAssertNotNil(sut.navigationItem.searchController, "navigationItem에 searchController가 설정되어야 함")
    }

    func test_searchController의_placeholder가_올바르게_설정되어_있다() {
        // given
        let searchController = sut.navigationItem.searchController

        // then
        XCTAssertEqual(
            searchController?.searchBar.placeholder,
            "Search repositories...",
            "searchBar placeholder가 올바르게 설정되어야 함"
        )
    }

    func test_searchController가_배경을_흐리게_하지_않는다() {
        // given
        let searchController = sut.navigationItem.searchController

        // then
        XCTAssertFalse(
            searchController?.obscuresBackgroundDuringPresentation ?? true,
            "검색 중 배경이 흐려지면 안 됨"
        )
    }

    // MARK: - Navigation 테스트

    func test_타이틀이_GitHub_Search로_설정되어_있다() {
        // then
        XCTAssertEqual(sut.title, "GitHub Search", "타이틀이 'GitHub Search'여야 함")
    }

    // MARK: - TableView 초기 상태 테스트

    func test_초기_상태에서_tableView_행이_0개이다() {
        // given
        let tableView = sut.view.subviews.compactMap { $0 as? UITableView }.first

        // then
        let rowCount = tableView?.numberOfRows(inSection: 0) ?? -1
        XCTAssertEqual(rowCount, 0, "초기 상태에서 tableView 행은 0개여야 함")
    }

    // MARK: - View Background 테스트

    func test_뷰_배경색이_systemBackground이다() {
        // then
        XCTAssertEqual(sut.view.backgroundColor, .systemBackground, "배경색이 systemBackground여야 함")
    }
}
