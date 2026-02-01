# Plan: GitHubSearch

**생성일**: 2026-02-01
**기준 문서**: spec.md

---

## 구현 순서

```
Phase 0: 프로젝트 기반 구축
    ↓
Issue #4: 검색 화면 - 기본 UI
    ↓
Issue #5: 검색 화면 - 최근 검색어
    ↓
Issue #6: 검색 결과 화면 - 리스트
    ↓
Issue #7: 검색 결과 화면 - WebView
    ↓
Issue #8: 페이지네이션 (추가)
    ↓
Issue #9: 자동완성 (추가)
```

---

## Phase 0: 프로젝트 기반 구축

### Task 0.1: SnapKit 의존성 추가
**파일**: `GitHubSearch.xcodeproj`

```
1. File > Add Package Dependencies
2. URL: https://github.com/SnapKit/SnapKit
3. Version: Up to Next Major (5.0.0)
```

### Task 0.2: 폴더 구조 생성
**파일**: 프로젝트 구조

```
GitHubSearch/
├── Application/
├── Domain/
│   ├── Entities/
│   ├── Protocols/
│   └── UseCases/
├── Data/
│   ├── Network/
│   ├── Repositories/
│   └── Storage/
├── Presentation/
│   ├── Search/
│   ├── SearchResult/
│   ├── WebView/
│   └── Common/
└── Resources/
```

### Task 0.3: 기본 Entity 생성
**파일**: `Domain/Entities/`

- [ ] `Repository.swift` - 저장소 모델
- [ ] `RecentSearch.swift` - 최근 검색어 모델
- [ ] `SearchResult.swift` - 검색 결과 모델

### Task 0.4: Protocol 정의
**파일**: `Domain/Protocols/`

- [ ] `NetworkServiceProtocol.swift`
- [ ] `SearchRepositoryProtocol.swift`
- [ ] `RecentSearchRepositoryProtocol.swift`

### Task 0.5: Network Layer 기본 구현
**파일**: `Data/Network/`

- [ ] `Endpoint.swift` - API Endpoint 정의
- [ ] `NetworkError.swift` - 에러 타입
- [ ] `NetworkService.swift` - URLSession 래퍼

**완료 조건**: 빌드 성공

---

## Issue #4: 검색 화면 - 기본 UI

### Task 4.1: SearchViewController 생성
**파일**: `Presentation/Search/SearchViewController.swift`

```swift
final class SearchViewController: UIViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()

    // UISearchController 설정
    // TableView 설정 (최근 검색어용)
}
```

**체크리스트**:
- [ ] UISearchController 설정
- [ ] navigationItem.searchController 연결
- [ ] TableView 기본 설정
- [ ] Storyboard 제거, 코드 기반 UI

### Task 4.2: SearchViewModel 생성
**파일**: `Presentation/Search/SearchViewModel.swift`

```swift
final class SearchViewModel {
    // Input
    func search(query: String)

    // Output
    var onSearchResult: ((SearchResult) -> Void)?
    var onError: ((Error) -> Void)?
}
```

**체크리스트**:
- [ ] 검색 실행 메서드
- [ ] 결과 콜백
- [ ] UseCase 의존성 주입

### Task 4.3: SceneDelegate 수정
**파일**: `Application/SceneDelegate.swift`

```swift
// Storyboard 제거 후 코드로 루트 설정
let searchVC = SearchViewController()
let nav = UINavigationController(rootViewController: searchVC)
window?.rootViewController = nav
```

**체크리스트**:
- [ ] Main.storyboard 참조 제거
- [ ] Info.plist에서 Storyboard 설정 제거
- [ ] 코드 기반 윈도우 설정

### Task 4.4: 검색 실행 연결
**파일**: `SearchViewController.swift`

```swift
// UISearchBarDelegate
func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces),
          !query.isEmpty else { return }
    viewModel.search(query: query)
}
```

**완료 조건**:
- [ ] 검색어 입력 후 Search 버튼 동작
- [ ] 빈 검색어 방지
- [ ] 결과 화면으로 이동 (임시 Alert)

---

## Issue #5: 검색 화면 - 최근 검색어

### Task 5.1: RecentSearchStorage 구현
**파일**: `Data/Storage/RecentSearchStorage.swift`

```swift
final class RecentSearchStorage {
    private let userDefaults: UserDefaults
    private let key = "recent_searches"
    private let maxCount = 10

    func getSearches() -> [RecentSearch]
    func saveSearch(_ query: String)
    func deleteSearch(_ query: String)
    func deleteAll()
}
```

**체크리스트**:
- [ ] Codable 저장/조회
- [ ] 중복 검색어 처리
- [ ] 최대 10개 제한
- [ ] 날짜 내림차순 정렬

### Task 5.2: RecentSearchRepository 구현
**파일**: `Data/Repositories/RecentSearchRepository.swift`

```swift
final class RecentSearchRepository: RecentSearchRepositoryProtocol {
    private let storage: RecentSearchStorage

    init(storage: RecentSearchStorage = RecentSearchStorage())
}
```

### Task 5.3: RecentSearchUseCase 구현
**파일**: `Domain/UseCases/RecentSearchUseCase.swift`

```swift
final class RecentSearchUseCase: RecentSearchUseCaseProtocol {
    private let repository: RecentSearchRepositoryProtocol
}
```

### Task 5.4: RecentSearchCell 구현
**파일**: `Presentation/Search/RecentSearchCell.swift`

```swift
final class RecentSearchCell: UITableViewCell {
    private let queryLabel = UILabel()
    private let timeLabel = UILabel()
    private let deleteButton = UIButton()

    var onDelete: (() -> Void)?
}
```

**체크리스트**:
- [ ] SnapKit Auto Layout
- [ ] 삭제 버튼 액션
- [ ] 상대 시간 표시

### Task 5.5: SearchViewController 최근 검색어 통합
**파일**: `SearchViewController.swift`

**체크리스트**:
- [ ] 최근 검색어 목록 표시
- [ ] 헤더 (전체 삭제 버튼)
- [ ] 개별 삭제
- [ ] 전체 삭제 시 Alert 확인
- [ ] 셀 탭 시 검색 실행

### Task 5.6: 날짜 포맷 유틸리티
**파일**: `Presentation/Common/RelativeDateFormatter.swift`

```swift
extension Date {
    var relativeString: String {
        // 방금 전, N분 전, N시간 전, N일 전, MM월 dd일
    }
}
```

**완료 조건**:
- [ ] 최근 검색어 저장/표시
- [ ] 개별/전체 삭제
- [ ] 앱 재시작 후 유지
- [ ] 탭 시 검색 실행

---

## Issue #6: 검색 결과 화면 - 리스트

### Task 6.1: SearchRepository 구현
**파일**: `Data/Repositories/SearchRepository.swift`

```swift
final class SearchRepository: SearchRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    func searchRepositories(query: String, page: Int) async throws -> SearchResult
}
```

### Task 6.2: SearchRepositoriesUseCase 구현
**파일**: `Domain/UseCases/SearchRepositoriesUseCase.swift`

```swift
final class SearchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol {
    private let repository: SearchRepositoryProtocol

    func execute(query: String, page: Int) async throws -> SearchResult
}
```

### Task 6.3: DTO 구현
**파일**: `Data/Network/DTOs/`

- [ ] `SearchResponseDTO.swift`
- [ ] `RepositoryDTO.swift`
- [ ] `OwnerDTO.swift`
- [ ] DTO → Entity 매핑

### Task 6.4: SearchResultViewController 생성
**파일**: `Presentation/SearchResult/SearchResultViewController.swift`

```swift
final class SearchResultViewController: UIViewController {
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView()

    private let viewModel: SearchResultViewModel
    private let query: String
}
```

**체크리스트**:
- [ ] 검색어 전달받아 검색 실행
- [ ] TableView 설정
- [ ] 상태별 UI (Loading, Success, Empty, Error)

### Task 6.5: SearchResultViewModel 구현
**파일**: `Presentation/SearchResult/SearchResultViewModel.swift`

```swift
final class SearchResultViewModel {
    enum State {
        case idle
        case loading
        case success(repositories: [Repository], totalCount: Int)
        case empty
        case error(Error)
    }

    var state: State
    func search(query: String)
}
```

### Task 6.6: RepositoryCell 구현
**파일**: `Presentation/SearchResult/RepositoryCell.swift`

```swift
final class RepositoryCell: UITableViewCell {
    private let avatarImageView = UIImageView()  // 40x40
    private let nameLabel = UILabel()            // Bold
    private let descriptionLabel = UILabel()     // 2줄
    private let starLabel = UILabel()            // ⭐ count
    private let languageLabel = UILabel()
}
```

**체크리스트**:
- [ ] SnapKit Auto Layout
- [ ] 이미지 비동기 로딩
- [ ] prepareForReuse 처리

### Task 6.7: ImageCache 구현
**파일**: `Presentation/Common/ImageCache.swift`

```swift
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    func image(for url: URL) async -> UIImage?
}
```

### Task 6.8: 결과 개수 헤더
**파일**: `SearchResultViewController.swift`

```swift
// TableView Header
"검색 결과 1,234,567개"
```

**완료 조건**:
- [ ] GitHub API 연동
- [ ] 검색 결과 목록 표시
- [ ] Avatar 이미지 로딩
- [ ] 결과 개수 표시
- [ ] 상태별 UI

---

## Issue #7: 검색 결과 화면 - WebView

### Task 7.1: WebViewController 구현
**파일**: `Presentation/WebView/WebViewController.swift`

```swift
final class WebViewController: UIViewController {
    private let webView = WKWebView()
    private let activityIndicator = UIActivityIndicatorView()

    private let url: URL
    private let repoName: String
}
```

**체크리스트**:
- [ ] WKWebView 설정
- [ ] URL 로드
- [ ] 로딩 상태 표시
- [ ] Navigation Title 설정

### Task 7.2: 셀 탭 → WebView 연결
**파일**: `SearchResultViewController.swift`

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let repo = viewModel.repository(at: indexPath.row)
    let webVC = WebViewController(url: repo.htmlUrl, title: repo.fullName)
    navigationController?.pushViewController(webVC, animated: true)
}
```

**완료 조건**:
- [ ] 셀 탭 시 WebView 이동
- [ ] GitHub 페이지 로드
- [ ] 뒤로가기 동작

---

## Issue #8: 페이지네이션 (추가)

### Task 8.1: SearchResultViewModel 페이지네이션 추가
**파일**: `SearchResultViewModel.swift`

```swift
private var currentPage = 1
private var isLoading = false
private var hasNextPage = true

func loadNextPage()
func shouldLoadMore(currentIndex: Int) -> Bool
```

### Task 8.2: 프리패칭 구현
**파일**: `SearchResultViewController.swift`

```swift
func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if viewModel.shouldLoadMore(currentIndex: indexPath.row) {
        viewModel.loadNextPage()
    }
}
```

### Task 8.3: 로딩 Footer 구현
**파일**: `SearchResultViewController.swift`

```swift
// TableView Footer에 ActivityIndicator
private let footerView = LoadingFooterView()
```

**완료 조건**:
- [ ] 스크롤 시 다음 페이지 로드
- [ ] 로딩 인디케이터 표시
- [ ] 중복 요청 방지
- [ ] 마지막 페이지 처리

---

## Issue #9: 자동완성 (추가)

### Task 9.1: 자동완성 UI 구현
**파일**: `SearchViewController.swift`

```swift
// UISearchResultsUpdating
func updateSearchResults(for searchController: UISearchController) {
    let text = searchController.searchBar.text ?? ""
    viewModel.filterRecentSearches(query: text)
}
```

### Task 9.2: 필터링 로직
**파일**: `SearchViewModel.swift`

```swift
func filterRecentSearches(query: String) {
    if query.isEmpty {
        // 전체 최근 검색어 표시
    } else {
        // prefix 매칭 필터
    }
}
```

**완료 조건**:
- [ ] 입력 시 필터링
- [ ] 날짜 함께 표시
- [ ] 선택 시 검색 실행

---

## 체크리스트 요약

### 필수 기능
- [ ] Phase 0: 프로젝트 기반 (Task 0.1~0.5)
- [ ] Issue #4: 검색 화면 기본 UI (Task 4.1~4.4)
- [ ] Issue #5: 최근 검색어 (Task 5.1~5.6)
- [ ] Issue #6: 검색 결과 리스트 (Task 6.1~6.8)
- [ ] Issue #7: WebView (Task 7.1~7.2)

### 추가 기능
- [ ] Issue #8: 페이지네이션 (Task 8.1~8.3)
- [ ] Issue #9: 자동완성 (Task 9.1~9.2)

---

**다음 단계**: plan-check (계획 검증)
