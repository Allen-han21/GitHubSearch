import XCTest
@testable import GitHubSearch

final class WebViewControllerTests: XCTestCase {

    // MARK: - Properties

    private var sut: WebViewController!
    private let testURL = URL(string: "https://github.com/test/repo")!
    private let testRepoName = "test-repo"

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        sut = WebViewController(url: testURL, repoName: testRepoName)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_초기화시_url이_올바르게_저장된다() {
        // then
        XCTAssertEqual(sut.url, testURL)
    }

    func test_초기화시_repoName이_올바르게_저장된다() {
        // then
        XCTAssertEqual(sut.repoName, testRepoName)
    }

    // MARK: - ViewDidLoad Tests

    func test_viewDidLoad_후_title이_repoName으로_설정된다() {
        // when
        sut.loadViewIfNeeded()

        // then
        XCTAssertEqual(sut.title, testRepoName)
    }

    func test_viewDidLoad_후_view_backgroundColor가_systemBackground이다() {
        // when
        sut.loadViewIfNeeded()

        // then
        XCTAssertEqual(sut.view.backgroundColor, .systemBackground)
    }

    // MARK: - URL Load Tests

    func test_viewDidLoad_후_올바른_URL로_load가_호출된다() {
        // when
        sut.loadViewIfNeeded()

        // then
        XCTAssertNotNil(sut.loadedRequest)
        XCTAssertEqual(sut.loadedRequest?.url, testURL)
    }

    func test_viewDidLoad_전에는_loadedRequest가_nil이다() {
        // then
        XCTAssertNil(sut.loadedRequest)
    }

    func test_다른_URL로_초기화하면_해당_URL로_load가_호출된다() {
        // given
        let anotherURL = URL(string: "https://github.com/another/repo")!
        let anotherSut = WebViewController(url: anotherURL, repoName: "another-repo")

        // when
        anotherSut.loadViewIfNeeded()

        // then
        XCTAssertEqual(anotherSut.loadedRequest?.url, anotherURL)
    }
}
