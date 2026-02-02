# Analyze: GitHubSearch

**생성일**: 2026-02-01
**기준 문서**: docs/PRD.md

---

## 1. 프로젝트 개요

### 목표
GitHub 저장소 검색 앱 개발

### 과제 기준
- [ ] 필수 기능 모두 동작
- [ ] 요구사항 순서대로 구현 (검색 화면 → 검색 결과 화면)
- [ ] 빌드 및 실행 성공
- [ ] AI 대화 로그 제출

---

## 2. 기능 요구사항 (PRD 기준)

### 2.1 검색 화면 (필수)

| ID | 기능 | 상세 |
|----|-----|------|
| S-1 | 검색 실행 | 검색어 입력 후 검색 결과 노출 |
| S-2 | 최근 검색어 표시 | 검색어 비어있을 시 최대 10개 노출 |
| S-3 | 정렬 | 날짜 기준 내림차순 |
| S-4 | 삭제 | 개별 삭제 / 전체 삭제 |
| S-5 | 영속성 | 앱 재시작 시 유지 |
| S-6 | 최근 검색어 선택 | 선택 시 검색 실행 |

### 2.2 검색 화면 (추가)

| ID | 기능 | 상세 |
|----|-----|------|
| S-A1 | 자동완성 | 검색어 입력 시 표시 |
| S-A2 | 자동완성 날짜 | 검색 날짜 함께 표시 |
| S-A3 | 자동완성 소스 | 최근 검색어에서 추출 |

### 2.3 검색 결과 화면 (필수)

| ID | 기능 | 상세 |
|----|-----|------|
| R-1 | 리스트 | 검색 결과 List 형태 |
| R-2 | 총 개수 | 총 검색 결과 수 표시 |
| R-3 | 저장소 정보 | Thumbnail(avatar_url), Title(name), Description(owner.login) |
| R-4 | 상세 이동 | 결과 선택 시 WebView를 통해 저장소로 이동 |

### 2.4 검색 결과 화면 (추가)

| ID | 기능 | 상세 |
|----|-----|------|
| R-A1 | 프리패칭 | 스크롤 중간에 Next Page 호출 |
| R-A2 | 로딩 상태 | Next Page 로딩 시 인디케이터 |

### API
```
[GET] https://api.github.com/search/repositories?q={keyword}&page={page}
```

---

## 3. GitHub Issues 현황

| # | 이슈 | 요구사항 |
|---|------|----------|
| 4 | 검색 화면 - 기본 UI | S-1 |
| 5 | 검색 화면 - 최근 검색어 | S-2~S-6 |
| 6 | 검색 결과 화면 - 리스트 | R-1~R-3 |
| 7 | 검색 결과 화면 - WebView | R-4 |
| 8 | 검색 결과 화면 - 페이지네이션 (추가) | R-A1~R-A2 |
| 9 | 검색 화면 - 자동완성 (추가) | S-A1~S-A3 |

**구현 순서**: #4 → #5 → #6 → #7 → #8 → #9

---

## 4. 기술 스택 (Apple 공식 문서 기반 검증)

### 4.1 Network: URLSession

| 항목 | 내용 |
|------|------|
| **공식 문서** | https://developer.apple.com/documentation/foundation/urlsession |
| **정의** | "An object that coordinates a group of related, network data transfer tasks" |
| **iOS 지원** | iOS 7.0+ |
| **선택 이유** | Apple 공식 네트워크 API, 외부 의존성 없음, async/await 지원 |

### 4.2 WebView: WKWebView

| 항목 | 내용 |
|------|------|
| **공식 문서** | https://developer.apple.com/documentation/webkit/wkwebview |
| **정의** | "An object that displays interactive web content" |
| **iOS 지원** | iOS 8.0+ |
| **선택 이유** | UIWebView deprecated, WKWebView가 유일한 선택지 |

### 4.3 Search UI: UISearchController

| 항목 | 내용 |
|------|------|
| **공식 문서** | https://developer.apple.com/documentation/uikit/uisearchcontroller |
| **정의** | "A view controller that manages the display of search results" |
| **iOS 지원** | iOS 8.0+ |
| **선택 이유** | Apple 표준 검색 패턴, UISearchDisplayController deprecated |

### 4.4 Image Cache: NSCache

| 항목 | 내용 |
|------|------|
| **공식 문서** | https://developer.apple.com/documentation/foundation/nscache |
| **정의** | "A mutable collection for transient key-value pairs subject to eviction" |
| **iOS 지원** | iOS 4.0+ |
| **선택 이유** | Thread-safe, 메모리 압박 시 자동 eviction |

### 4.5 Persistence: UserDefaults

| 항목 | 내용 |
|------|------|
| **공식 문서** | https://developer.apple.com/documentation/foundation/userdefaults |
| **정의** | "An interface to the user's defaults database" |
| **iOS 지원** | iOS 2.0+ |
| **선택 이유** | 소량 데이터 (검색어 10개), 앱 재시작 시 유지 |

---

## 5. 아키텍처 설계

### 5.1 선택: Clean Architecture + MVVM

| 항목 | 선택 | 이유 |
|------|------|------|
| **Architecture** | Clean Architecture + MVVM | 레이어 분리, 테스트 용이 |
| **UI** | UIKit + SnapKit | 간결한 Auto Layout, 실무 친화적 |
| **DI 패턴** | Protocol 기반 Constructor Injection | Mock 주입으로 테스트 용이 |

### 5.2 레이어 구조

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
├─────────────────────────────────────────────────────────────┤
│  ViewController ──▶ ViewModel                                │
│                        │                                     │
│                        └── UseCaseProtocol                   │
├─────────────────────────────────────────────────────────────┤
│                        Domain Layer                          │
├─────────────────────────────────────────────────────────────┤
│  UseCase ──▶ RepositoryProtocol                             │
│  Entities (Repository, RecentSearch)                         │
├─────────────────────────────────────────────────────────────┤
│                         Data Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Repository ──▶ NetworkServiceProtocol / Storage            │
│  NetworkService, RecentSearchStorage                         │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 DI 패턴 (Protocol 기반)

```swift
// Protocol 정의
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

protocol SearchRepositoryProtocol {
    func searchRepositories(query: String, page: Int) async throws -> SearchResult
}

// Constructor Injection + Default Parameter
final class SearchViewModel {
    private let searchUseCase: SearchRepositoriesUseCaseProtocol

    init(searchUseCase: SearchRepositoriesUseCaseProtocol = SearchRepositoriesUseCase()) {
        self.searchUseCase = searchUseCase
    }
}

// 테스트 시 Mock 주입
let mockUseCase = MockSearchUseCase()
let viewModel = SearchViewModel(searchUseCase: mockUseCase)
```

---

## 6. 프로젝트 구조 (예정)

```
GitHubSearch/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── DIContainer.swift
├── Domain/
│   ├── Entities/
│   │   ├── Repository.swift
│   │   └── RecentSearch.swift
│   ├── Protocols/
│   │   ├── SearchRepositoryProtocol.swift
│   │   └── RecentSearchRepositoryProtocol.swift
│   └── UseCases/
│       ├── SearchRepositoriesUseCase.swift
│       └── RecentSearchUseCase.swift
├── Data/
│   ├── Network/
│   │   ├── Endpoint.swift
│   │   ├── NetworkService.swift
│   │   └── GitHubAPI.swift
│   ├── Repositories/
│   │   ├── SearchRepository.swift
│   │   └── RecentSearchRepository.swift
│   └── Storage/
│       └── RecentSearchStorage.swift
├── Presentation/
│   ├── Search/
│   │   ├── SearchViewController.swift
│   │   ├── SearchViewModel.swift
│   │   └── RecentSearchCell.swift
│   ├── SearchResult/
│   │   ├── SearchResultViewController.swift
│   │   ├── SearchResultViewModel.swift
│   │   └── RepositoryCell.swift
│   ├── WebView/
│   │   └── WebViewController.swift
│   └── Common/
│       └── ImageCache.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

## 7. 엣지 케이스 및 고려사항

### 7.1 네트워크
- [ ] API Rate Limit (60 req/hour for unauthenticated)
- [ ] 네트워크 오류 처리 (타임아웃, 연결 실패)
- [ ] 빈 검색 결과 처리

### 7.2 검색
- [ ] 빈 검색어 방지
- [ ] 연속 검색 debounce
- [ ] 검색 중 취소 처리

### 7.3 최근 검색어
- [ ] 중복 검색어 처리 (기존 항목 업데이트)
- [ ] 10개 초과 시 가장 오래된 항목 삭제
- [ ] 특수문자 포함 검색어

### 7.4 페이지네이션
- [ ] 마지막 페이지 도달 감지
- [ ] 중복 요청 방지
- [ ] 로딩 중 추가 요청 차단

### 7.5 이미지
- [ ] 이미지 로딩 실패 시 placeholder
- [ ] 셀 재사용 시 이미지 취소

---

## 8. 확인 필요 사항

1. **SnapKit 의존성**: SPM으로 추가 예정 (확인 완료)
2. **최소 iOS 버전**: iOS 15.0+ (async/await 지원)
3. **API 인증**: 미인증 (Rate Limit 60 req/hour)

---

**다음 단계**: spec.md 작성 (상세 스펙 정의)
