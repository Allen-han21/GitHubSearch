# Plan: 자동완성 기능 (Issue #9)

## Task 목록

### Task 9.1: UseCase 확장
**파일**: `GitHubSearch/Domain/UseCases/RecentSearchUseCase.swift`

**변경 내용**:
1. Protocol에 `getAutocompleteSuggestions(for:)` 메서드 추가
2. UseCase에 구현 추가

**코드**:
```swift
// Protocol 추가
func getAutocompleteSuggestions(for query: String) -> [RecentSearch]

// 구현
func getAutocompleteSuggestions(for query: String) -> [RecentSearch] {
    guard !query.isEmpty else { return [] }
    let lowercasedQuery = query.lowercased()
    return repository.getSearches()
        .filter { $0.query.lowercased().contains(lowercasedQuery) }
}
```

---

### Task 9.2: ViewModel 확장
**파일**: `GitHubSearch/Presentation/Search/SearchViewModel.swift`

**변경 내용**:
1. `autocompleteSuggestions` 속성 추가
2. `isSearching` 속성 추가
3. `updateAutocomplete(query:isActive:)` 메서드 추가
4. `autocompleteSuggestion(at:)` 메서드 추가

**코드**:
```swift
// 속성
private(set) var autocompleteSuggestions: [RecentSearch] = []
private(set) var isSearching: Bool = false

// 메서드
func updateAutocomplete(query: String, isActive: Bool) {
    isSearching = isActive && !query.isEmpty
    if isSearching {
        autocompleteSuggestions = recentSearchUseCase.getAutocompleteSuggestions(for: query)
    } else {
        autocompleteSuggestions = []
    }
    onRecentSearchesUpdated?()
}

func autocompleteSuggestion(at index: Int) -> RecentSearch? {
    guard index < autocompleteSuggestions.count else { return nil }
    return autocompleteSuggestions[index]
}
```

---

### Task 9.3: ViewController 수정
**파일**: `GitHubSearch/Presentation/Search/SearchViewController.swift`

**변경 내용**:

1. **updateSearchResults 구현** (line 166-168)
```swift
func updateSearchResults(for searchController: UISearchController) {
    let query = searchController.searchBar.text ?? ""
    viewModel.updateAutocomplete(query: query, isActive: searchController.isActive)
}
```

2. **numberOfRowsInSection 수정** (line 186-188)
```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.isSearching
        ? viewModel.autocompleteSuggestions.count
        : viewModel.recentSearches.count
}
```

3. **cellForRowAt 수정** (line 190-205)
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(...) as? RecentSearchCell else {
        return UITableViewCell()
    }

    let recentSearch: RecentSearch?
    if viewModel.isSearching {
        recentSearch = viewModel.autocompleteSuggestion(at: indexPath.row)
        cell.configure(with: recentSearch, showDeleteButton: false)
    } else {
        recentSearch = viewModel.recentSearch(at: indexPath.row)
        cell.configure(with: recentSearch)
        cell.onDelete = { [weak self] in
            self?.viewModel.deleteRecentSearch(at: indexPath.row)
        }
    }

    return cell
}
```

4. **didSelectRowAt 수정** (line 210-216)
```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let query: String?
    if viewModel.isSearching {
        query = viewModel.autocompleteSuggestion(at: indexPath.row)?.query
    } else {
        query = viewModel.recentSearch(at: indexPath.row)?.query
    }

    guard let query else { return }
    searchController.isActive = false
    viewModel.search(query: query)
}
```

5. **updateHeaderVisibility 수정** (line 121-128)
```swift
private func updateHeaderVisibility() {
    if viewModel.isSearching || viewModel.recentSearches.isEmpty {
        tableView.tableHeaderView = nil
    } else {
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableHeaderView = headerView
    }
}
```

---

### Task 9.4: RecentSearchCell 수정 (선택적)
**파일**: `GitHubSearch/Presentation/Search/Views/RecentSearchCell.swift`

자동완성 모드에서 삭제 버튼을 숨기기 위한 옵션 추가:

```swift
func configure(with recentSearch: RecentSearch?, showDeleteButton: Bool = true) {
    // 기존 로직...
    deleteButton.isHidden = !showDeleteButton
}
```

---

### Task 9.5: 테스트 추가
**파일**: `GitHubSearchTests/RecentSearchUseCaseTests.swift` (신규 또는 확장)

```swift
func test_getAutocompleteSuggestions_빈쿼리_빈배열반환() {
    let result = sut.getAutocompleteSuggestions(for: "")
    XCTAssertTrue(result.isEmpty)
}

func test_getAutocompleteSuggestions_매칭있음_필터링된결과() {
    // "swift", "swiftui", "react" 저장 후
    let result = sut.getAutocompleteSuggestions(for: "sw")
    XCTAssertEqual(result.count, 2)
}

func test_getAutocompleteSuggestions_대소문자무시() {
    // "Swift" 저장 후
    let result = sut.getAutocompleteSuggestions(for: "SWIFT")
    XCTAssertEqual(result.count, 1)
}
```

**파일**: `GitHubSearchTests/SearchViewModelTests.swift` (확장)

```swift
func test_updateAutocomplete_검색중상태전환() {
    sut.updateAutocomplete(query: "test", isActive: true)
    XCTAssertTrue(sut.isSearching)

    sut.updateAutocomplete(query: "", isActive: true)
    XCTAssertFalse(sut.isSearching)
}
```

---

## 실행 순서

```
Task 9.1 (UseCase)
    ↓
Task 9.2 (ViewModel)
    ↓
Task 9.3 (ViewController)
    ↓
Task 9.4 (Cell - 선택적)
    ↓
Task 9.5 (테스트)
    ↓
커밋
```

---

## 커밋 계획

```
feat(#9): 자동완성 기능 추가

- RecentSearchUseCase에 getAutocompleteSuggestions 추가
- SearchViewModel에 자동완성 상태 관리 추가
- SearchViewController에 UISearchResultsUpdating 구현
- 자동완성 테스트 추가
```
