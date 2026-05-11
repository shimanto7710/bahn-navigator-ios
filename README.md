# BahnNavigator

A SwiftUI journey planner inspired by Deutsche Bahn's DB Navigator, built as a portfolio project to demonstrate modern iOS engineering practices. The companion backend — a small ML-augmented routing API — lives in a separate repository and will be hosted independently.

## Features

- **Search** — debounced station autocomplete with an offline cache so previously searched stations load instantly without the network.
- **Journey results** — VoiceOver-friendly cards showing departure / arrival times, duration, transport line badges, and number of changes.
- **Nearby** — location-based station search using `CoreLocation`.
- **Saved journeys** — persisted with SwiftData, swipe-to-delete.
- **Profile** — grouped settings list.

## Architecture

Feature-based MVVM with a Repository layer between Presentation and the network / local store.

```
BahnNavigator/
├── App/                          BahnNavigatorApp.swift + SwiftData container
├── Core/
│   ├── Location/                 LocationManager (CLLocation wrapper)
│   └── Network/                  APIClient, APIEndpoint, APIError, AppConfiguration
├── DesignSystem/
│   ├── AppColors.swift           Color.appDark, Color.appRed (+ UIColor companion)
│   └── Components/               LoadingView, ErrorView
└── features/
    ├── Home/                     Tab bar shell + NavigationStack
    ├── SearchJourney/
    │   ├── Presentation/         View + ViewModel + LocationPickerSheet
    │   └── data/
    │       ├── Models/           Codable DTOs
    │       ├── Local/            SwiftData entity + LocationLocalDataSource
    │       ├── Remote/           LocationService
    │       └── Repository/       LocationRepository (cache + remote)
    ├── JourneyResults/
    ├── Journeys/                 Saved searches (SwiftData)
    ├── Nearby/
    └── Profile/
```

### Why these choices

- **Protocol-based DI** — every service and data source is fronted by a protocol with an `init` default. Tests inject in-memory fakes; production wiring stays implicit.
- **Repository layer** — Presentation never talks to `APIClient` or `SwiftData` directly. Switching cache strategy or API client only touches one file.
- **`@MainActor` ViewModels** — state mutations are statically guaranteed to be on the main thread; no manual `DispatchQueue.main.async` calls.
- **`async/await` + `Task.checkCancellation()`** — the SwiftUI `.task` modifier auto-cancels in-flight work when a view disappears; the ViewModels cooperate by checking for cancellation between stages.
- **Tolerant decoding** — `TransportProduct` falls back to `.unknown` for unrecognised raw values and `Journey`/`JourneyLeg` synthesise an `id` when the API omits `refreshToken`/`tripId`, so a new product type or schema change never crashes the decoder.

## Tech stack

- **Swift 5 / iOS 18.5**, Xcode 16
- **SwiftUI** with `NavigationStack` and the `#Preview` macro
- **SwiftData** for the local cache and saved journeys
- **Swift Testing** for unit tests

## Run it locally

1. Open `BahnNavigator.xcodeproj` in Xcode 16.
2. Point [`AppConfiguration.baseURL`](BahnNavigator/Core/Network/AppConfiguration.swift) at your backend (defaults to `http://localhost:3000`).
3. Select the iPhone 16 Pro simulator and **⌘R**.

To run the unit test suite: **⌘U** (or `xcodebuild test -scheme BahnNavigator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'`).

## Roadmap

- Hosted ML backend for delay / connection-reliability prediction (separate project)
- German localization
- Push notifications for journey changes
- Live activity for an in-progress journey
