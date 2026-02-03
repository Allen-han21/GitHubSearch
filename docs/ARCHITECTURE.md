# Architecture

## 개요
GitHubSearch는 **Clean Architecture + MVVM** 구조를 사용합니다.

### 선택 이유
1. **관심사 분리**: Presentation / Domain / Data 레이어 분리로 각 레이어의 책임 명확화
2. **테스트 용이성**: Protocol 기반 의존성 주입으로 Mock 객체를 통한 단위 테스트 가능
3. **유지보수성**: UI 변경이 비즈니스 로직에 영향을 주지 않음
4. **MVVM**: ViewController의 비대화 방지, View와 로직 분리

---

## 레이어 구조

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

### 레이어별 역할
- **Presentation**: 화면 구성, 사용자 입력 처리, 상태 바인딩
- **Domain**: 비즈니스 규칙, UseCase, Repository Protocol
- **Data**: API/Storage 구현, DTO 변환

---

## 의존성 규칙
- Presentation → Domain → Data 방향으로 의존
- Domain은 인터페이스(Protocol)만 정의하고, Data가 구현
- 외부 의존성은 바깥 레이어에서만 사용

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

## DI 전략
- Constructor Injection 사용
- 테스트 시 Mock 주입을 통한 단위 테스트 용이성 확보
