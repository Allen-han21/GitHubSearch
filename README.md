# GitHubSearch

GitHub 저장소 검색 iOS 앱

## 스크린샷

| 검색 화면 | 최근 검색어 | 검색 결과 | WebView |
|:---:|:---:|:---:|:---:|
| 검색어 입력 | 최근 검색어 목록 | 저장소 리스트 | GitHub 페이지 |
|<img src="https://github.com/user-attachments/assets/e700b286-5743-4397-8b30-41b331ddc22b" width="200" />|<img src="https://github.com/user-attachments/assets/04b54333-4f7d-4217-9d4c-a4c28f021737" width="200" />|<img src="https://github.com/user-attachments/assets/58de10cf-b6f3-4ed2-ad35-82e0658742d3" width="200" />|<img src="https://github.com/user-attachments/assets/ebac2abb-08bb-4643-a4c0-c23d4a54dfe0" width="200" />|

---

## 아키텍처

### Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ViewController│  │  ViewModel  │  │    Cell     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                       Domain                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Entity    │  │   UseCase   │  │  Protocol   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                        Data                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Repository │  │   Network   │  │   Storage   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### 선택 이유

1. **관심사 분리**: Presentation / Domain / Data 레이어 분리로 각 레이어의 책임 명확화
2. **테스트 용이성**: Protocol 기반 의존성 주입으로 Mock 객체를 통한 단위 테스트 가능
3. **유지보수성**: UI 변경이 비즈니스 로직에 영향을 주지 않음
4. **MVVM**: ViewController의 비대화 방지, View와 로직 분리

---

## 기술 스택

| 영역 | 기술 | 선택 이유 |
|------|------|----------|
| UI Framework | UIKit + SnapKit | 코드 기반 Auto Layout, 가독성 향상 |
| Architecture | Clean Architecture + MVVM | 테스트 용이성, 관심사 분리 |
| Network | URLSession (async/await) | 외부 의존성 최소화, Swift Concurrency 활용 |
| WebView | WKWebView | 시스템 제공, 성능 최적화 |
| Image Cache | NSCache | 메모리 기반 캐싱, 간단한 구현 |
| Persistence | UserDefaults | 최근 검색어 저장, 간단한 데이터에 적합 |
| DI | Constructor Injection | 테스트 시 Mock 주입 용이 |
| iOS Target | 15.0+ | async/await 지원 |

---

## 구현 기능

### 필수 기능 (모두 완료)

#### 검색 화면
- [x] 검색어 입력 및 검색 실행
- [x] 최근 검색어 목록 표시 (최대 10개)
- [x] 날짜 기준 내림차순 정렬
- [x] 개별 삭제 / 전체 삭제
- [x] 앱 재시작 시 유지 (UserDefaults)
- [x] 최근 검색어 선택 시 검색 실행

#### 검색 결과 화면
- [x] 검색 결과 리스트 표시
- [x] 총 검색 결과 수 표시
- [x] 저장소 정보 표시 (Avatar, Name, Description, Stars, Language)
- [x] 결과 선택 시 WebView로 GitHub 페이지 이동

### 추가 기능 (미구현)
- [ ] 페이지네이션 (프리패칭)
- [ ] 자동완성

---

## 프로젝트 구조

```
GitHubSearch/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Domain/
│   ├── Entities/
│   │   ├── Repository.swift
│   │   ├── SearchResult.swift
│   │   └── RecentSearch.swift
│   ├── Protocols/
│   │   ├── NetworkServiceProtocol.swift
│   │   ├── SearchRepositoryProtocol.swift
│   │   └── RecentSearchRepositoryProtocol.swift
│   └── UseCases/
│       ├── RecentSearchUseCase.swift
│       └── SearchRepositoriesUseCase.swift
├── Data/
│   ├── Network/
│   │   ├── Endpoint.swift
│   │   ├── NetworkError.swift
│   │   ├── NetworkService.swift
│   │   └── DTOs/
│   │       └── SearchResponseDTO.swift
│   ├── Repositories/
│   │   ├── RecentSearchRepository.swift
│   │   └── SearchRepository.swift
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
│       ├── RelativeDateFormatter.swift
│       └── ImageCache.swift
└── Resources/
```

---

## 빌드 및 실행

### 요구사항
- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+

### 실행 방법
```bash
# 1. 프로젝트 열기
open GitHubSearch.xcodeproj

# 2. Xcode에서 Run (Cmd + R)
```

### 의존성
- **SnapKit** (SPM): Auto Layout DSL

---

## 테스트

### 테스트 실행
```bash
xcodebuild test -scheme GitHubSearch -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### 테스트 현황

| 테스트 파일 | 테스트 수 | 설명 |
|------------|----------|------|
| SearchViewModelTests | 15 | 검색 ViewModel 로직 |
| SearchViewControllerTests | 9 | 검색 화면 UI 설정 |
| RecentSearchStorageTests | 8 | 최근 검색어 저장소 |
| SearchResultViewModelTests | 11 | 검색 결과 ViewModel |
| SearchResponseDTOTests | 7 | API 응답 DTO 파싱 |
| WebViewControllerTests | 5 | WebView 화면 |

**총 55개 테스트 / 100% 통과**

---

## API

### GitHub Search Repositories API

```
GET https://api.github.com/search/repositories?q={keyword}&page={page}
```

### 응답 예시
```json
{
  "total_count": 12345,
  "items": [
    {
      "id": 1,
      "name": "swift",
      "full_name": "apple/swift",
      "owner": {
        "login": "apple",
        "avatar_url": "https://..."
      },
      "html_url": "https://github.com/apple/swift",
      "description": "The Swift Programming Language",
      "stargazers_count": 60000,
      "language": "Swift"
    }
  ]
}
```

---

## 관련 문서

- [PRD](docs/PRD.md) - 요구사항 정의서
- [AI 대화 로그](docs/AI_CONVERSATION_LOG.md) - Claude Code 대화 기록

---

## 개발 기간

- **시작**: 2026-02-01
- **완료**: 2026-02-01
- **AI 도구**: Claude Code (Anthropic)
