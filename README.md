# Product_APP
# Product Management App — Flutter Assessment

## Overview

A production-quality Flutter application for managing products with clean architecture, offline support, and a polished UI.

---

## Setup Instructions

### Prerequisites

- Flutter SDK: **3.24.x (Stable Channel)**
- Dart: **3.5+**
- Android Studio / VS Code with Flutter plugin
- Git

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Jaswanth0402/Product_APP.git
cd Product_APP

# 2. Install dependencies
flutter pub get

# 3. Generate code (models, mocks)
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### Run Tests

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# All tests
flutter test
```

### Build APK

```bash
flutter build apk --release
```

---

## Architecture

### Clean Architecture

The project follows **Clean Architecture** with three distinct layers per feature:

```
Presentation  →  Domain  ←  Data
   (UI)         (Business)  (API/DB)
```

- **Data Layer**: API calls (Dio), local storage (Hive), models, repository impl
- **Domain Layer**: Entities, repository contracts, use cases
- **Presentation Layer**: Screens, widgets, Riverpod providers

### Folder Structure

```
lib/
├── core/
│   ├── constants/       # API endpoints, app constants
│   ├── network/         # Dio client, interceptors, error handling
│   ├── services/        # Connectivity, local storage service
│   ├── theme/           # Light/dark theme definitions
│   └── utils/           # Extensions, validators, helpers
│
├── features/
│   ├── products/
│   │   ├── data/
│   │   │   ├── datasources/  # Remote + local data sources
│   │   │   ├── models/       # JSON-serializable models
│   │   │   └── repositories/ # Repository implementations
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/     # Pure Dart entities
│   │   │   ├── repositories/ # Abstract repository contracts
│   │   │   └── usecases/     # Single-responsibility use cases
│   │   │
│   │   └── presentation/
│   │       ├── screens/      # Product list, detail, add, edit
│   │       ├── widgets/      # Reusable UI components
│   │       └── providers/    # Riverpod providers & state notifiers
│   │
│   └── settings/
│       └── presentation/
│           ├── screens/      # Settings screen
│           └── providers/    # Theme provider
│
├── shared/
│   └── widgets/         # App-wide reusable widgets
│
└── main.dart
```

---

## State Management — Riverpod

**Chosen**: Riverpod (v2 with code generation)

**Why Riverpod over Bloc/Provider?**

1. **Compile-time safety** — `@riverpod` annotations catch errors at build time, not runtime.
2. **No BuildContext required** — providers are globally accessible, making service-layer testing trivial.
3. **Fine-grained reactivity** — `select()` lets widgets rebuild only when the specific slice of state they care about changes, reducing unnecessary repaints.
4. **First-class async support** — `AsyncNotifier` and `FutureProvider` handle loading/error/data states declaratively without boilerplate.
5. **Easy DI** — `ref.watch` / `ref.read` replaces `get_it` for most injection needs.

---

## Local Storage Strategy

**Chosen**: Hive

- `recently_viewed_box` — stores up to 10 recently viewed product IDs (used to hydrate the detail screen fast on revisit).
- `settings_box` — stores `themeMode` (`light` / `dark`) as a string.
- **Why Hive over SharedPreferences**: Hive supports typed boxes and custom adapters, making it far more ergonomic for structured data like product objects.

---

## Networking

- **Dio** with a centralized `ApiClient` (`core/network/api_client.dart`)
- 30-second connect/receive timeout
- `DioException` mapped to domain-level `AppError` types (network, server, parse)
- Retry interceptor for transient failures

---

## Offline Support

- `connectivity_plus` monitors connection state via a stream
- `ConnectivityProvider` (Riverpod) exposes `isOnline` globally
- `OfflineBanner` widget auto-shows when offline
- Products list is cached to Hive on every successful fetch; stale data is shown when offline

---

## Assumptions

1. The `POST /products/add` and `PUT /products/{id}` endpoints on dummyjson.com do not persist data server-side — updates are applied locally in Riverpod state and reflected immediately in the UI.
2. Pagination is implemented with `limit=20&skip=N` query params; the total is read from `response.total`.
3. Product images may occasionally fail to load (CDN variance) — `cached_network_image` handles this with a placeholder and error widget.
4. "Recently viewed" is capped at 10 items, FIFO.

---

## Packages Used

| Package | Purpose |
|---|---|
| `flutter_riverpod` + `riverpod_annotation` | State management + DI |
| `dio` | HTTP client |
| `hive_flutter` | Local storage |
| `connectivity_plus` | Network monitoring |
| `cached_network_image` | Image caching |
| `go_router` | Navigation |
| `carousel_slider` | Product image carousel |
| `json_annotation` + `json_serializable` | Model serialization |
| `build_runner` | Code generation |
| `flutter_smart_debouncer` | Search debounce |
| `shimmer` | Loading skeleton UI |
| `infinite_scroll_pagination` | Paginated product list |

---

Important:
I Do only for Android Because i don't have Device to handle IOS