# AI 협업 개발 기록

## 개요

| 항목 | 내용 |
|------|------|
| **개발 기간** | 2026-02-01 ~ 2026-02-03 |
| **AI 도구** | Claude Code (Anthropic Claude Opus 4.5) |
| **워크플로우** | ai-dev 커스텀 워크플로우 |
| **총 대화 세션** | 11개 Phase (~8,600줄) |

---

## 개발 방식

- GitHub Issue 기반으로 작업 단위를 관리했습니다.
- ai-dev 워크플로우 산출물은 `docs/ai-dev/`에 정리했습니다.
- 원본 대화 로그는 `docs/prompts/`에 보관했습니다.
- **Sentinel 패턴**: 장기 세션에서 컨텍스트 임계치 도달 시 자동 저장/복원으로 연속성 유지

---

## AI 개발 워크플로우

체계적인 AI 협업 개발을 위해 커스텀 워크플로우를 사용했습니다.

```
┌──────────┐   ┌────────┐   ┌────────┐   ┌─────────────┐
│ analyze  │ → │  spec  │ → │  plan  │ → │ plan-check  │
│ 요구분석 │   │ 스펙정의│   │ 계획수립│   │  계획검증   │
└──────────┘   └────────┘   └────────┘   └─────────────┘
                                                │
      ┌─────────────────────────────────────────┘
      ▼
┌──────────┐   ┌────────────┐   ┌────────────┐   ┌────────┐
│   impl   │ → │ code-check │ → │ work-check │ → │ review │
│ 코드구현 │   │  품질검사  │   │  버그검사  │   │ 리뷰   │
└──────────┘   └────────────┘   └────────────┘   └────────┘
```

### 각 단계별 역할

| 단계 | 설명 | 산출물 |
|------|------|--------|
| **analyze** | PRD + 코드베이스 분석, 엣지케이스 식별 | [01-analyze.md](ai-dev/01-analyze.md) |
| **spec** | 기술 스택 결정, 상세 스펙 정의 | [02-spec.md](ai-dev/02-spec.md) |
| **plan** | Task 단위 구현 계획 수립 | [03-plan.md](ai-dev/03-plan.md) |
| **plan-check** | 5개 validators로 계획 검증 | [04-plan-check-report.md](ai-dev/04-plan-check-report.md) |
| **impl** | Task별 구현 + 로컬 커밋 + 테스트 | 소스 코드 |
| **code-check** | DRY/SOLID/Complexity 분석 | [05-code-check-report.md](ai-dev/05-code-check-report.md) |
| **work-check** | 6개 병렬 bug checkers | [06-work-check-report.md](ai-dev/06-work-check-report.md) |
| **review** | 비즈니스 규칙 검증 + 최종 판정 | [07-review-report.md](ai-dev/07-review-report.md) |

## 검증 도구 구성

### plan-check (계획 검증)
- completeness-checker: spec→plan 요구사항 누락 검사
- pattern-compliance: AGENTS.md 컨벤션 준수 검사
- feasibility-assessor: 기술적 실현 가능성 평가
- risk-assessor: 회귀/보안 위험 평가
- scope-discipline: 과잉 구현(gold-plating) 탐지
- devil's advocate: 오탐(false positive) 감소

### code-check (코드 품질 검증)
- DRY Checker: 중복 코드 탐지
- SOLID Checker: 설계 원칙 위반 검사
- Complexity Analyzer: 순환 복잡도 분석

### work-check (버그 탐지)
- Edge Case Hunter: 경계 조건 누락 탐지
- Race Condition Detector: 동시성 문제 탐지
- State Corruption Finder: 상태 오염 탐지
- Memory Leak Hunter: 메모리 누수 탐지
- Input Validation Checker: 입력 검증 누락 탐지
- Regression Detector: 회귀 버그 탐지

## 개발 도구 및 참고 문서

### Claude Code (Opus 4.5)
- 요구사항 분석부터 코드 검증까지 상호작용에 활용

### Apple Developer Docs (apple-docs MCP)

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

### HIG (Human Interface Guidelines)
- Accessibility: accessibilityLabel 명시, SearchBar/Cell/DeleteButton 음성 설명
- Clear Visual Hierarchy: 스펙 2.1, 2.2의 레이아웃 설계
- Feedback: 로딩 상태, 에러 처리
- Consistency: 일관된 UI 패턴

### SourceKit-LSP
- 정의로 이동 (Go to Definition)
- 참조 찾기 (Find References)
- 심볼 검색

### CodeRabbit AI
- 최종 코드 리뷰 단계에서 CodeRabbit + 비즈니스 규칙 검증

---

## 주요 기술 토론

### 1. 아키텍처 선택 (Phase 2)

**토론 주제**: Clean Architecture vs VIPER vs MVC

**AI와의 대화 요약**:
- MVC: 빠른 구현 가능하지만 ViewController 비대화 우려
- VIPER: 과제 규모에 비해 과도한 복잡도
- Clean Architecture + MVVM: 테스트 용이성, 관심사 분리, 적절한 복잡도

**결정**: Clean Architecture + MVVM
- Data / Domain / Presentation 레이어 분리
- Protocol 기반 의존성 주입으로 테스트 용이성 확보

### 2. 자동완성 필터링 로직 위치 (Phase 10)

**토론 주제**: 필터링 로직을 어디에 둘 것인가?

| 위치 | 장점 | 단점 |
|------|------|------|
| Repository | 데이터 레이어에서 처리 | SRP 위반 |
| **UseCase** | 비즈니스 로직 담당 계층 | ✅ 권장 |
| ViewModel | UI와 가까움 | 비즈니스 로직이 Presentation에 침투 |

**결정**: UseCase에 `getAutocompleteSuggestions(for:)` 메서드 추가
- Clean Architecture 원칙 준수
- 재사용 가능한 비즈니스 로직

### 3. Race Condition 분석 (Phase 9)

**발견된 이슈**:
1. `ImageCache` - 동일 URL 중복 다운로드
2. `RecentSearchStorage` - 동시 저장 시 데이터 유실

**AI 분석**:
```
Thread 1: read cache → miss → start download
Thread 2: read cache → miss → start download (중복!)
```

**해결책**:
- 진행 중인 요청을 추적하는 Dictionary 도입
- `NSLock`으로 동기화

### 4. UISearchController 상태 관리 (Phase 11)

**이슈**: 키보드 Search 버튼 클릭 시 검색 결과 화면으로 이동 안 됨

**원인 분석**:
```swift
// Before (문제)
searchController.isActive = false  // dismiss 시 상태 변경
viewModel.search(query: query)     // 콜백 호출 안 됨

// After (해결)
viewModel.search(query: query)     // 먼저 검색 실행
searchController.isActive = false  // 그 다음 dismiss
```

**결정**: 호출 순서 변경으로 해결

---

## 품질 검증 결과

### code-check (품질 검사)

| 항목 | 결과 |
|------|------|
| **등급** | **A (우수)** |
| DRY | ✅ 중복 코드 없음 |
| SOLID | ✅ 설계 원칙 준수 |
| Complexity | ✅ 적절한 복잡도 |
| Pattern Consistency | ✅ 일관된 패턴 |
| Test Coverage | ✅ 68개 테스트 |

### work-check (버그 검사)

| 심각도 | 발견 수 | 주요 내용 |
|--------|---------|----------|
| P0 Critical | 3건 | Race Condition, 에러 알림 부재 |
| P1 High | 6건 | Task 취소, 입력 검증 |
| P2 Medium | 7건 | 에러 로깅, URL 검증 |
| P3 Low | 5건 | 상수화, 최적화 |

### review (최종 판정)

**결과**: ⚠️ 조건부 승인
- 요구사항 구현율: 100% (필수) + 100% (추가)
- P0 버그 존재하나 과제 맥락에서 허용 가능

---

## Step by Step 개발 과정

| Phase | 파일 | 내용 | 주요 토론 |
|-------|------|------|----------|
| 1 | [phase-01](prompts/phase-01-prd-issues.txt) | PRD 작성, GitHub Issue 등록 | 요구사항 분석 |
| 2 | [phase-02](prompts/phase-02-analyze-spec.txt) | 요구사항 분석, 스펙 정의 | 아키텍처 선택 |
| 3 | [phase-03](prompts/phase-03-plan-setup.txt) | 구현 계획, 프로젝트 설정 | 폴더 구조 |
| 4 | [phase-04](prompts/phase-04-search-ui.txt) | 검색 화면 기본 UI | UISearchController |
| 5 | [phase-05](prompts/phase-05-recent-search.txt) | 최근 검색어 기능 | UserDefaults 영속성 |
| 6 | [phase-06](prompts/phase-06-search-result.txt) | 검색 결과 화면 | 비동기 상태 관리 |
| 7 | [phase-07](prompts/phase-07-webview.txt) | WebView 화면 | WKWebView 설정 |
| 8 | [phase-08](prompts/phase-08-pagination.txt) | 페이지네이션 | 프리패칭 전략 |
| 9 | [phase-09](prompts/phase-09-quality-review.txt) | 품질 검사, 코드 리뷰 | Race Condition |
| 10 | [phase-10](prompts/phase-10-autocomplete.txt) | 자동완성 기능 | 필터링 로직 위치 |
| 11 | [phase-11](prompts/phase-11-final-polish.txt) | 버그 수정, 마무리 | 상태 관리 |

---

## 전체 대화 로그

원본 대화 기록은 [prompts/](prompts/) 폴더에서 확인할 수 있습니다.

```
docs/prompts/
├── phase-01-prd-issues.txt      (32KB)
├── phase-02-analyze-spec.txt    (44KB)
├── phase-03-plan-setup.txt      (60KB)
├── phase-04-search-ui.txt       (43KB)
├── phase-05-recent-search.txt   (10KB)
├── phase-06-search-result.txt   (23KB)
├── phase-07-webview.txt         (58KB)
├── phase-08-pagination.txt      (19KB)
├── phase-09-quality-review.txt  (13KB)
├── phase-10-autocomplete.txt    (48KB)
└── phase-11-final-polish.txt    (81KB)
```

---

## AI 워크플로우 산출물

상세 분석/설계 문서는 [ai-dev/](ai-dev/) 폴더에서 확인할 수 있습니다.

| 문서 | 설명 |
|------|------|
| [01-analyze.md](ai-dev/01-analyze.md) | 요구사항 분석, 엣지케이스 식별 |
| [02-spec.md](ai-dev/02-spec.md) | 기술 스택, 상세 스펙 |
| [03-plan.md](ai-dev/03-plan.md) | Task 단위 구현 계획 |
| [04-plan-check-report.md](ai-dev/04-plan-check-report.md) | 계획 검증 결과 |
| [05-code-check-report.md](ai-dev/05-code-check-report.md) | 품질 검사 결과 |
| [06-work-check-report.md](ai-dev/06-work-check-report.md) | 버그 검사 결과 |
| [07-review-report.md](ai-dev/07-review-report.md) | 코드 리뷰 결과 |
