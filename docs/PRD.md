# PRD: GitHubSearch

## 1. 목표

### 프로젝트 목표
GitHub 저장소 검색 앱 개발

### 과제 안내 기준 목표
- [ ] 필수 기능 모두 동작
- [ ] 요구사항 순서대로 구현 (검색 화면 → 검색 결과 화면)
- [ ] 빌드 및 실행 성공
- [ ] AI 대화 로그 제출

---

## 2. 기능 요구사항

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
(Ex. https://api.github.com/search/repositories?q=swift&page=1)

---


## 3. 실행 계획

### GitHub Issue 관리

| # | 이슈 |
|---|-----|
| 1 | PRD 작성 |
| 2 | [setup] 프로젝트 초기 설정 |
| 3 | [setup] AI 어시스턴트 (Claude Code) 설정 |
| 4 | [feature] 검색 화면 - 기본 UI |
| 5 | [feature] 검색 화면 - 최근 검색어 |
| 6 | [feature] 검색 결과 화면 - 리스트 |
| 7 | [feature] 검색 결과 화면 - WebView |
| 8 | [feature] 검색 결과 화면 - 페이지네이션 (추가) | 
| 9 | [feature] 검색 화면 - 자동완성 (추가) |

### 구현 순서

```
검색 화면 (필수) → 검색 결과 화면 (필수) → 추가 기능
```

---

## 5. 제출물
```
GitHubSearch/
├── README.md
├── CLAUDE.md
├── docs/
│   ├── PRD.md
│   └── AI_CONVERSATION_LOG.md
└── GitHubSearch.xcodeproj/
```