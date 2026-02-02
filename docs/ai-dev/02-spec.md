# Spec: GitHubSearch

**생성일**: 2026-02-01
**기준 문서**: analyze.md

---

## 1. 데이터 모델

### 1.1 API Response

```swift
// GitHub Search API Response
struct SearchResponse: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [RepositoryDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct RepositoryDTO: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let owner: OwnerDTO
    let description: String?
    let htmlUrl: String
    let stargazersCount: Int
    let language: String?

    enum CodingKeys: String, CodingKey {
        case id, name, owner, description, language
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
    }
}

struct OwnerDTO: Decodable {
    let login: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}
```

### 1.2 Domain Entity

```swift
struct Repository {
    let id: Int
    let name: String
    let ownerName: String
    let avatarUrl: String
    let description: String?
    let htmlUrl: String
    let starCount: Int
    let language: String?
}

struct SearchResult {
    let totalCount: Int
    let repositories: [Repository]
    let hasNextPage: Bool
}

struct RecentSearch {
    let query: String
    let searchedAt: Date
}
```

---

## 2. 화면별 상세 스펙

### 2.1 검색 화면 (SearchViewController)

#### 2.1.1 UI 구성
```
┌─────────────────────────────────────┐
│ ┌─────────────────────────────────┐ │
│ │  🔍 GitHub 저장소 검색          │ │  ← UISearchController
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  최근 검색어              [전체 삭제] │  ← Header
├─────────────────────────────────────┤
│  swift                    ✕   2분 전 │  ← RecentSearchCell
│  kotlin                   ✕   1시간 전│
│  react                    ✕   어제    │
│  ...                                 │
└─────────────────────────────────────┘
```

#### 2.1.2 동작 스펙

| 동작 | 스펙 |
|------|------|
| **검색 실행** | Search 버튼 탭 또는 키보드 Search 키 |
| **검색어 유효성** | 공백 제거 후 1자 이상 |
| **최근 검색어 표시** | 검색 TextField가 비어있을 때만 표시 |
| **최근 검색어 최대** | 10개, 초과 시 가장 오래된 항목 삭제 |
| **최근 검색어 정렬** | 검색 날짜 내림차순 (최신이 위) |
| **최근 검색어 탭** | 해당 검색어로 검색 실행 |
| **개별 삭제** | ✕ 버튼 탭 시 해당 항목만 삭제 |
| **전체 삭제** | Alert 확인 후 전체 삭제 |
| **중복 검색어** | 기존 항목 삭제 후 최상단에 추가 |

#### 2.1.3 상태

| 상태 | UI |
|------|-----|
| **Empty** | 검색어 입력 + 최근 검색어 목록 (있으면) |
| **No Recent** | 검색어 입력 + "최근 검색어가 없습니다" |

---

### 2.2 검색 결과 화면 (SearchResultViewController)

#### 2.2.1 UI 구성
```
┌─────────────────────────────────────┐
│ ← swift              Cancel         │  ← Navigation + SearchBar
├─────────────────────────────────────┤
│  검색 결과 377,878개                 │  ← Result Count Header
├─────────────────────────────────────┤
│ ┌───┐ swiftlang/swift               │
│ │ 🖼 │ The Swift Programming...      │  ← RepositoryCell
│ └───┘ ⭐ 69,627  C++                 │
├─────────────────────────────────────┤
│ ┌───┐ apple/swift-nio               │
│ │ 🖼 │ Event-driven network...       │
│ └───┘ ⭐ 8,234  Swift                │
├─────────────────────────────────────┤
│  ...                                 │
│                                      │
│         ⏳ Loading...                │  ← 페이지네이션 로딩
└─────────────────────────────────────┘
```

#### 2.2.2 동작 스펙

| 동작 | 스펙 |
|------|------|
| **검색 실행** | 화면 진입 시 자동 검색 |
| **결과 표시** | totalCount 숫자 포맷 (1,234,567) |
| **셀 구성** | Avatar(40x40) + Name(bold) + Description(2줄) + Star + Language |
| **셀 탭** | WebViewController로 html_url 이동 |
| **프리패칭** | 남은 항목 5개 이하일 때 다음 페이지 요청 |
| **로딩 표시** | Footer에 ActivityIndicator |
| **마지막 페이지** | 더 이상 요청하지 않음 |
| **새 검색** | SearchBar에서 검색 시 결과 초기화 후 재검색 |

#### 2.2.3 상태

| 상태 | UI |
|------|-----|
| **Loading** | 중앙 ActivityIndicator |
| **Success** | 검색 결과 목록 |
| **Empty** | "검색 결과가 없습니다" |
| **Error** | 오류 메시지 + 재시도 버튼 |
| **LoadingMore** | Footer ActivityIndicator |

---

### 2.3 WebView 화면 (WebViewController)

#### 2.3.1 UI 구성
```
┌─────────────────────────────────────┐
│ ← swiftlang/swift                   │  ← Navigation Title
├─────────────────────────────────────┤
│                                      │
│         [WKWebView]                  │
│                                      │
│                                      │
├─────────────────────────────────────┤
│  ◀  ▶  🔄  [━━━━━━━━━━━]           │  ← Progress Bar (Optional)
└─────────────────────────────────────┘
```

#### 2.3.2 동작 스펙

| 동작 | 스펙 |
|------|------|
| **URL 로드** | 진입 시 html_url 로드 |
| **타이틀** | Repository full_name 표시 |
| **로딩 표시** | 상단 Progress Bar 또는 ActivityIndicator |
| **에러 처리** | Alert 표시 후 dismiss |

---

## 3. API 스펙

### 3.1 Endpoint

```swift
enum GitHubEndpoint {
    case searchRepositories(query: String, page: Int)

    var url: URL {
        switch self {
        case .searchRepositories(let query, let page):
            var components = URLComponents(string: "https://api.github.com/search/repositories")!
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: "30")
            ]
            return components.url!
        }
    }
}
```

### 3.2 Rate Limit
- **미인증**: 60 requests/hour (IP 기준)
- **인증**: 30 requests/minute

### 3.3 에러 처리

| HTTP Status | 처리 |
|-------------|------|
| 200 | 성공 |
| 304 | Not Modified (캐시 사용) |
| 403 | Rate Limit 초과 → 사용자 안내 |
| 422 | Validation Failed → 검색어 확인 |
| 503 | Service Unavailable → 재시도 안내 |

---

## 4. 저장소 스펙 (RecentSearch)

### 4.1 저장 형식

```swift
// UserDefaults Key
static let recentSearchesKey = "recent_searches"

// 저장 구조 (Codable)
struct RecentSearchDTO: Codable {
    let query: String
    let searchedAt: Date
}

// Array<RecentSearchDTO>를 JSON으로 저장
```

### 4.2 동작 규칙

| 동작 | 규칙 |
|------|------|
| **저장 시점** | 검색 실행 직후 (결과 성공/실패 무관) |
| **중복 처리** | 기존 항목 삭제 → 새 항목으로 최상단 추가 |
| **최대 개수** | 10개, 초과 시 가장 오래된 항목 삭제 |
| **삭제** | 개별 삭제, 전체 삭제 지원 |

---

## 5. 이미지 캐싱 스펙

### 5.1 구현 방식

```swift
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        // 1. 메모리 캐시 확인
        if let cached = cache.object(forKey: key) {
            return cached
        }

        // 2. 네트워크 요청
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }

        // 3. 캐시 저장
        cache.setObject(image, forKey: key)
        return image
    }
}
```

### 5.2 셀 재사용 처리

```swift
// 셀 재사용 시 이전 요청 취소
func prepareForReuse() {
    imageLoadTask?.cancel()
    avatarImageView.image = placeholder
}
```

---

## 6. 날짜 포맷 스펙

### 6.1 최근 검색어 날짜 표시

| 조건 | 표시 |
|------|------|
| 1분 미만 | "방금 전" |
| 1시간 미만 | "N분 전" |
| 24시간 미만 | "N시간 전" |
| 7일 미만 | "N일 전" |
| 7일 이상 | "MM월 dd일" |

---

## 7. 접근성 (Accessibility)

| 요소 | 접근성 |
|------|--------|
| SearchBar | accessibilityLabel: "저장소 검색" |
| RecentSearchCell | accessibilityLabel: "{query}, {시간}" |
| DeleteButton | accessibilityLabel: "{query} 삭제" |
| RepositoryCell | accessibilityLabel: "{name}, {description}, 별 {count}개" |

---

## 8. 테스트 시나리오

### 8.1 Unit Test

| 대상 | 테스트 항목 |
|------|------------|
| SearchViewModel | 검색 실행, 최근 검색어 저장/삭제 |
| SearchResultViewModel | 페이지네이션, 상태 변환 |
| RecentSearchUseCase | 저장/조회/삭제/중복처리 |
| ImageCache | 캐시 저장/조회 |
| DateFormatter | 상대 시간 포맷 |

### 8.2 UI Test

| 화면 | 테스트 항목 |
|------|------------|
| 검색 화면 | 검색 실행, 최근 검색어 표시/삭제 |
| 결과 화면 | 스크롤, 셀 탭, 페이지네이션 |
| WebView | URL 로드, 뒤로가기 |

---

**다음 단계**: plan.md 작성 (상세 구현 계획)
