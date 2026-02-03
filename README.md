# GitHubSearch

GitHub 저장소 검색 iOS 앱

## TL;DR
- GitHub 저장소 검색 앱 (필수/추가 구현 완료)
- UIKit 기반, Clean Architecture + MVVM
- 테스트 68개 / 100% 통과
- 상세 문서: PRD / Architecture / AI Collaboration / Prompts

## Quick Links
- PRD: [docs/PRD.md](docs/PRD.md)
- Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- AI Collaboration: [docs/AI-COLLABORATION.md](docs/AI-COLLABORATION.md)
- Prompts: [docs/prompts/](docs/prompts/)

## Requirements Coverage
### 검색 화면
- [x] 검색어 입력 후 검색
- [x] 최근 검색어 최대 10개 (내림차순)
- [x] 개별 삭제 / 전체 삭제
- [x] 앱 재시작 후 유지
- [x] 최근 검색어 선택 시 검색

### 검색 결과 화면
- [x] List 형태 표시
- [x] 총 검색 결과 수 표시
- [x] Thumbnail / Title / Description 매핑
- [x] 선택 시 WebView 이동

### 추가 구현
- [x] 자동완성 (최근 검색어 기반, 날짜 표시)
- [x] 페이지네이션 프리패치
- [x] Next Page 로딩 상태 표시

## Architecture
Clean Architecture + MVVM
- 관심사 분리로 레이어 책임 명확화
- Protocol 기반 DI로 테스트 용이성 확보
- ViewController 비대화 방지 및 유지보수성 개선

## Tech Stack
| 영역 | 기술 |
|------|------|
| UI | UIKit + SnapKit |
| Architecture | Clean Architecture + MVVM |
| Network | URLSession (async/await) |
| WebView | WKWebView |
| Cache | NSCache |
| Persistence | UserDefaults |
| DI | Constructor Injection |
| iOS Target | 15.0+ |

## Build & Run
```bash
open GitHubSearch.xcodeproj
```

## Tests
- 총 68개 / 100% 통과
- 테스트 실행 방법은 [docs/PRD.md](docs/PRD.md) 참고
- 상세 테스트 현황은 [docs/PRD.md](docs/PRD.md) 참고

## Screenshots

| 검색 화면 | 최근 검색어 | 검색 결과 | WebView |
|:---:|:---:|:---:|:---:|
| 검색어 입력 | 최근 검색어 목록 | 저장소 리스트 | GitHub 페이지 |
|<img src="https://github.com/user-attachments/assets/e700b286-5743-4397-8b30-41b331ddc22b" width="200" />|<img src="https://github.com/user-attachments/assets/04b54333-4f7d-4217-9d4c-a4c28f021737" width="200" />|<img src="https://github.com/user-attachments/assets/58de10cf-b6f3-4ed2-ad35-82e0658742d3" width="200" />|<img src="https://github.com/user-attachments/assets/ebac2abb-08bb-4643-a4c0-c23d4a54dfe0" width="200" />|

## AI Collaboration
- 상세 기록: [docs/AI-COLLABORATION.md](docs/AI-COLLABORATION.md)
- 원본 대화 로그: [docs/prompts/](docs/prompts/)

## Issues
- https://github.com/Allen-han21/GitHubSearch/issues
