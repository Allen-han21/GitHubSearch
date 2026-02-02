# Spec: 자동완성 기능 (Issue #9)

## 요구사항

| 항목 | 설명 |
|------|------|
| 기능 | 검색어 입력 시 자동완성 표시 |
| 데이터 소스 | 최근 검색어 |
| 표시 정보 | 검색어 + 검색 날짜 |

---

## 기술 결정

### 1. 데이터 소스
- **선택**: 기존 `RecentSearchRepository` 재사용
- **이유**: 최근 검색어가 자동완성 소스이므로 새 저장소 불필요

### 2. 필터링 로직 위치
- **선택**: `RecentSearchUseCase`에 메서드 추가
- **이유**:
  - Clean Architecture 원칙 (비즈니스 로직은 UseCase)
  - Repository는 데이터 접근만 담당
  - ViewModel은 UI 상태 관리에 집중

### 3. UI 구현 방식
- **선택**: 기존 TableView 재사용 (Option A)
- **이유**:
  - 최소 코드 변경
  - 기존 `RecentSearchCell` 재사용
  - `UISearchResultsUpdating` 이미 구현됨

---

## 변경 범위

### 1. Domain Layer

**RecentSearchUseCaseProtocol** (메서드 추가)
```swift
func getAutocompleteSuggestions(for query: String) -> [RecentSearch]
```

**RecentSearchUseCase** (구현 추가)
```swift
func getAutocompleteSuggestions(for query: String) -> [RecentSearch] {
    guard !query.isEmpty else { return [] }
    return repository.getSearches()
        .filter { $0.query.lowercased().contains(query.lowercased()) }
}
```

### 2. Presentation Layer

**SearchViewModel** (속성/메서드 추가)
```swift
// 속성
private(set) var autocompleteSuggestions: [RecentSearch] = []
private(set) var isSearching: Bool = false

// 메서드
func updateAutocomplete(query: String, isActive: Bool)
func autocompleteSuggestion(at index: Int) -> RecentSearch?
```

**SearchViewController** (변경)
- `updateSearchResults(for:)` 구현
- `numberOfRowsInSection` 분기 처리
- `cellForRowAt` 분기 처리
- `didSelectRowAt` 분기 처리
- Header 가시성 분기 처리

---

## 데이터 흐름

```
[사용자 입력 "sw"]
       ↓
UISearchResultsUpdating.updateSearchResults(for:)
       ↓
viewModel.updateAutocomplete(query: "sw", isActive: true)
       ↓
useCase.getAutocompleteSuggestions(for: "sw")
       ↓
repository.getSearches() → 필터링
       ↓
["swift", "swiftui"] 반환
       ↓
viewModel.autocompleteSuggestions 업데이트
       ↓
onRecentSearchesUpdated?() 콜백
       ↓
tableView.reloadData()
       ↓
isSearching=true → autocompleteSuggestions 표시
```

---

## UI 상태

| 상태 | 표시 내용 | Header |
|------|----------|--------|
| 초기 (isSearching=false) | 전체 최근 검색어 | "최근 검색" + 전체삭제 |
| 검색 중 (isSearching=true, 입력 있음) | 필터링된 자동완성 | 숨김 |
| 검색 중 (isSearching=true, 입력 없음) | 빈 목록 | 숨김 |

---

## 테스트 케이스

### UseCase 테스트
1. 빈 쿼리 → 빈 배열 반환
2. 매칭 없음 → 빈 배열 반환
3. 부분 매칭 → 필터링된 결과 반환
4. 대소문자 무시 매칭

### ViewModel 테스트
1. isSearching 상태 전환
2. autocompleteSuggestions 업데이트
3. autocompleteSuggestion(at:) 인덱스 처리

### ViewController 테스트
1. 검색 중 자동완성 표시
2. 자동완성 선택 시 검색 실행
3. Header 가시성 전환

---

## 완료 조건

- [ ] 검색어 입력 시 자동완성 목록 표시
- [ ] 최근 검색어에서 prefix/contains 매칭
- [ ] 검색 날짜 함께 표시 (기존 Cell 재사용)
- [ ] 자동완성 항목 선택 시 검색 실행
- [ ] 테스트 코드 추가
