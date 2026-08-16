# AgriVault (Farmio) Mobile

A standalone, fully offline Flutter app for farm management. It gives farmers and farm staff a phone-native way to log field work, track crops and harvests, manage finances, and pull compliance-ready reports — with no network connection required at all, ever.

All data lives in an on-device SQLite database. There is no backend, no login, and no account — the app is locked with a local PIN instead, and every screen reads and writes straight to the device.

## Features

**Farm operations**
- Fields — area, soil type, allocation, and a per-field detail view
- GPS field mapping — draw field boundaries, zones, and farm markers on an interactive map
- Crops — planting-to-harvest lifecycle, status, crop timelines with due/overdue alerts, and harvest/yield price suggestions
- Activities — labour, input, and other-cost logging per crop or field
- Seasonal templates and season-to-season comparison (with an overall "which season did better" verdict)

**Business**
- Finance — income/expense transactions, overhead costs, category breakdowns
- Employees — payroll roles and labour capacity, grouped by role
- Inventory — stock levels, low-stock flags, and sales
- Equipment — fuel/service logs and maintenance records

**Livestock**
- Animal register, health, production, and weight records

**Insights & compliance**
- Reports — season/crop/field/labour/input/yield breakdowns, charts, and on-device PDF/CSV export
- Records — loan, buyer, audit, and insurance evidence packs
- Traceability and compliance checklists
- Weather forecast by farm location, pulled directly from Open-Meteo
- Notifications generated on-device from crop timelines, upcoming harvests, and low stock

## Tech stack

| Concern              | Library                                   |
|-----------------------|--------------------------------------------|
| State management      | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Routing               | [go_router](https://pub.dev/packages/go_router) |
| Local database         | [drift](https://pub.dev/packages/drift) (SQLite) |
| Weather API client     | [dio](https://pub.dev/packages/dio) (Open-Meteo only) |
| PIN storage            | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) + [crypto](https://pub.dev/packages/crypto) |
| Charts                | [fl_chart](https://pub.dev/packages/fl_chart) |
| Maps                  | [flutter_map](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2) |
| PDF export            | [pdf](https://pub.dev/packages/pdf) |
| File export & share    | [path_provider](https://pub.dev/packages/path_provider) + [share_plus](https://pub.dev/packages/share_plus) |
| Fonts                 | [google_fonts](https://pub.dev/packages/google_fonts) |

## Architecture

- **`lib/core/db`** — the drift schema (`app_database.dart`), a shared per-crop cost/revenue/yield aggregator used by the reports/dashboard/report-builder screens, and small coercion helpers for form input.
- **`lib/core/auth`** — local PIN-lock: a salted hash in secure storage, a Riverpod state notifier, and the router redirect that gates every screen behind it.
- **`lib/features/<name>`** — one folder per feature, each following the same `*_repository.dart` → `*_provider.dart` → `*_screen.dart` shape: the repository queries drift directly, the provider exposes it to the UI via Riverpod, and the screen consumes it.
- **`lib/models`** — hand-written `fromJson`/`toJson` models. Table column names are chosen to match these models' JSON keys, so most repository reads are just `Model.fromJson(row.toJson())`.
- **`lib/shared`** — reusable widgets (cards, summary bars, error banners, filters) and formatting utilities used across features.

## Getting started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ≥3.0.0, <4.0.0)

### Setup

```bash
flutter pub get
```

If you change the drift schema in `lib/core/db/app_database.dart`, regenerate the generated code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run
```

On first launch the app asks you to set a PIN, then creates its local database — no other setup is needed.

## Testing

```bash
flutter test
```

Most coverage lives in `test/db/`: one file per repository, exercising it against an in-memory drift database (`NativeDatabase.memory()`).

## Project structure

```
lib/
├── core/           # drift schema + aggregator, PIN auth, router, theme
├── features/       # one folder per feature (repository + provider + screen)
├── models/         # data models with fromJson/toJson
└── shared/         # reusable widgets, filters, formatters
test/
├── core/           # PIN lock, secure storage
├── db/             # repository tests against an in-memory database
├── models/         # model parsing
└── shared/         # utility logic (e.g. yield pricing)
```
