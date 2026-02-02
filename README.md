# GitHubSearch

GitHub 저장소 검색 iOS 앱

## 문서 경로

```
docs/
├── PRD.md                          # 요구사항 정의서
├── AI-COLLABORATION.md             # AI 협업 기록, 주요 토론
├── ai-dev/
│   ├── 01-analyze.md               # 요구사항 분석
│   ├── 02-spec.md                  # 스펙 정의
│   ├── 03-plan.md                  # 구현 계획
│   ├── 04-plan-check-report.md     # 계획 검증 결과
│   ├── 05-code-check-report.md     # 품질 검사 결과
│   ├── 06-work-check-report.md     # 버그 검사 결과
│   └── 07-review-report.md         # 코드 리뷰 결과
└── prompts/ (대화 원본)
    ├── phase-01-prd-issues.txt     # PRD 작성, GitHub Issue
    ├── phase-02-analyze-spec.txt   # 요구사항 분석, 스펙 정의
    ├── phase-03-plan-setup.txt     # 구현 계획, 프로젝트 설정
    ├── phase-04-search-ui.txt      # 검색 화면 기본 UI
    ├── phase-05-recent-search.txt  # 최근 검색어 기능
    ├── phase-06-search-result.txt  # 검색 결과 화면
    ├── phase-07-webview.txt        # WebView 화면
    ├── phase-08-pagination.txt     # 페이지네이션
    ├── phase-09-quality-review.txt # 품질 검사, 코드 리뷰
    ├── phase-10-autocomplete.txt   # 자동완성 기능
    └── phase-11-final-polish.txt   # 버그 수정, 마무리
```

**바로가기**: [PRD](docs/PRD.md) | [AI 협업 기록](docs/AI-COLLABORATION.md) | [원본 대화 로그](docs/prompts/)

---

## AI 활용 개발

### 개발 방식

- **GitHub Issue 기반**: [Issues](https://github.com/Allen-han21/GitHubSearch/issues?q=is%3Aissue) 개발 진행 관리 

### ai-dev 워크플로우

커스텀 워크플로우를 사용했습니다.

```
analyze → spec → plan → plan-check → impl → code-check → work-check → review
```

| 단계 | 설명 | 주요 활동 |
|------|------|----------|
| **analyze** | 요구사항 분석 | PRD 분석, 아키텍처 선택 |
| **spec** | 스펙 정의 | 기술 스택 결정 
| **plan** | 계획 수립 | Task 단위 구현 계획 수립 |
| **plan-check** | 계획 검증 | 5개 validators로 계획 검증 |
| **impl** | 코드 구현 | Task별 구현 + 로컬 커밋 + 테스트 |
| **code-check** | 품질 검사 | DRY, SOLID, Complexity, Pattern Consistency, Test Support 분석 |
| **work-check** | 버그 검사 | 6개 Bug Checkers로 버그 검사 |
| **review** | 최종 리뷰 | 비즈니스 규칙 검증 + 판정 |

**Sentinel 패턴**: 장기 세션에서 컨텍스트 임계치 도달 시 자동 저장/복원으로 연속성 유지

### 각 단계별 검증 도구

| 단계 | 도구/검증자 | 산출물 |
|------|------------|--------|
| plan-check | 5개 validators + Devil's Advocate | [04-plan-check-report.md](docs/ai-dev/04-plan-check-report.md) |
| code-check | DRY/SOLID/Complexity 분석 | [05-code-check-report.md](docs/ai-dev/05-code-check-report.md) |
| work-check | 6개 Bug Checkers | [06-work-check-report.md](docs/ai-dev/06-work-check-report.md) |
| review | CodeRabbit + 비즈니스 규칙 | [07-review-report.md](docs/ai-dev/07-review-report.md) |

**Plan-Check (계획 검증: 5개 Validators + Devil's Advocate)**

| Validator | 역할 |
|-----------|------|
| completeness-checker | spec→plan 요구사항 누락 검사 |
| pattern-compliance | AGENTS.md 컨벤션 준수 검사 |
| feasibility-assessor | 기술적 실현 가능성 평가 |
| risk-assessor | 회귀/보안 위험 평가 |
| scope-discipline | 과잉 구현(gold-plating) 탐지 |
| + devil's advocate | 오탐(false positive) 감소 |

**Code-Check (코드 품질 검증)**
- **DRY Checker**: 중복 코드 탐지
- **SOLID Checker**: 설계 원칙 위반 검사
- **Complexity Analyzer**: 순환 복잡도 분석

**Work-Check (버그 탐지: 6개 Bug Checkers)**
- **Edge Case Hunter**: 경계 조건 누락 탐지
- **Race Condition Detector**: 동시성 문제 탐지
- **State Corruption Finder**: 상태 오염 탐지
- **Memory Leak Hunter**: 메모리 누수 탐지
- **Input Validation Checker**: 입력 검증 누락 탐지
- **Regression Detector**: 회귀 버그 탐지

---

### 개발 도구

#### Claude Code (Opus 4.5)

AI 협업 개발의 메인 도구. 워크플로우 활용하여 요구사항 분석부터 코드 검증까지 상호작용.


#### Apple Developer Docs (apple-docs MCP)

기술 스택 결정 단계에서 Apple 공식 API 검증에 활용.

| API | 공식 문서 | iOS 지원 |
|-----|----------|----------|
| URLSession | [developer.apple.com](https://developer.apple.com/documentation/foundation/urlsession) | iOS 7.0+ |
| WKWebView | [developer.apple.com](https://developer.apple.com/documentation/webkit/wkwebview) | iOS 8.0+ |
| UISearchController | [developer.apple.com](https://developer.apple.com/documentation/uikit/uisearchcontroller) | iOS 8.0+ |
| NSCache | [developer.apple.com](https://developer.apple.com/documentation/foundation/nscache) | iOS 4.0+ |
| UserDefaults | [developer.apple.com](https://developer.apple.com/documentation/foundation/userdefaults) | iOS 2.0+ |

**선택 이유**
- URLSession: Apple 공식 네트워크 API, 외부 의존성 없음, async/await 지원
- WKWebView: UIWebView deprecated, WKWebView가 유일한 선택지
- UISearchController: Apple 표준 검색 패턴
- NSCache: Thread-safe, 메모리 압박 시 자동 eviction
- UserDefaults: 소량 데이터 영속성 (검색어 10개)

#### HIG (Human Interface Guidelines)
UI/UX 설계에 반영.

- **Accessibility**: accessibilityLabel 명시, SearchBar/Cell/DeleteButton 음성 설명
- **Clear Visual Hierarchy**: 스펙 2.1, 2.2의 레이아웃 설계
- **Feedback**: 로딩 상태, 에러 처리
- **Consistency**: 일관된 UI 패턴

#### SourceKit-LSP

Swift Language Server를 통한 코드 탐색 및 분석.

- 정의로 이동 (Go to Definition)
- 참조 찾기 (Find References)
- 심볼 검색


#### CodeRabbit AI

최종 코드 리뷰 단계에서 CodeRabbit + 비즈니스 규칙 검증.


---

## 요구사항 구현

> **'검색 화면' → '검색 결과 화면' 순서로 구현**했습니다.

### 1. 검색 화면 (먼저 구현)

**필수 기능**
- [x] 검색어 입력 후 검색 결과 표시
- [x] 최근 검색어 최대 10개 표시
- [x] 날짜 기준 내림차순 정렬
- [x] 개별 삭제 / 전체 삭제
- [x] 앱 재시작 시에도 유지 (UserDefaults)
- [x] 최근 검색어 선택 시 검색 실행

**추가 구현**
- [x] 자동완성 (최근 검색어 기반, 검색 날짜 표시)

### 2. 검색 결과 화면 (그 다음 구현)

**필수 기능**
- [x] 검색 결과 List 형태 표시
- [x] 총 검색 결과 수 표시
- [x] 저장소 정보 (Thumbnail, Title, Description)
- [x] 선택 시 WebView로 GitHub 페이지 이동

**추가 구현**
- [x] 페이지네이션 (프리패칭)
- [x] Next Page 로딩 상태 표시

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

## 프로젝트 구조

```
GitHubSearch/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
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

## 스크린샷

| 검색 화면 | 최근 검색어 | 검색 결과 | WebView |
|:---:|:---:|:---:|:---:|
| 검색어 입력 | 최근 검색어 목록 | 저장소 리스트 | GitHub 페이지 |
|<img src="https://github.com/user-attachments/assets/e700b286-5743-4397-8b30-41b331ddc22b" width="200" />|<img src="https://github.com/user-attachments/assets/04b54333-4f7d-4217-9d4c-a4c28f021737" width="200" />|<img src="https://github.com/user-attachments/assets/58de10cf-b6f3-4ed2-ad35-82e0658742d3" width="200" />|<img src="https://github.com/user-attachments/assets/ebac2abb-08bb-4643-a4c0-c23d4a54dfe0" width="200" />|

---

## 테스트

### 테스트 실행
```bash
xcodebuild test -scheme GitHubSearch -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### 테스트 현황

| 테스트 파일 | 테스트 수 | 설명 |
|------------|----------|------|
| SearchViewModelTests | 22 | 검색 ViewModel 로직 + 자동완성 |
| SearchViewControllerTests | 9 | 검색 화면 UI 설정 |
| RecentSearchStorageTests | 8 | 최근 검색어 저장소 |
| RecentSearchUseCaseTests | 5 | 자동완성 필터링 로직 |
| SearchResultViewModelTests | 11 | 검색 결과 ViewModel |
| SearchResponseDTOTests | 7 | API 응답 DTO 파싱 |
| WebViewControllerTests | 6 | WebView 화면 |

**총 68개 테스트 / 100% 통과**

---
