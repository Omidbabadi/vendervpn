# CLAUDE.md — vendervpn

## Project Overview
Cross-platform Flutter VPN client (`vendervpn`) backed by self-hosted Appwrite (`https://vender.flutterdevs.top/v1`) and 3x-ui/Xray servers, enforcing daily device-attested 500 MB free quotas + 500 MB AdMob rewarded bonuses.

## Architecture & Directory Structure
Follow strict **Clean Architecture** matching this exact folder layout (do NOT create a `lib/features` directory):
- `lib/core/` — Shared config (`AppConfig`), error/failure types (`Equatable`), network clients (`Dio`/Appwrite), theme (`Pallet`), and reusable stateless UI components (`lib/core/widgets/`).
- `lib/core/common/entities/` — Shared pure Dart domain entities (`Equatable`) used across modules (zero Flutter, JSON serialization, or third-party SDK imports).
- `lib/src/` — Application modules (e.g. `lib/src/admob/`, VPN, quota/auth) organized into `domain/`, `data/`, and `presentation/`:
  - `domain/` — Repository interfaces and use cases referencing `lib/core/common/entities/` (zero Flutter or SDK imports).
  - `data/models/` — Serialization/DTO models that extend or map to entities in `lib/core/common/entities/`.
  - `data/datasources/` — Third-party SDK and API integrations (e.g. `google_mobile_ads`, Appwrite, `flutter_v2ray_client`). SDK/plugin imports belong here, never in `domain/` or `presentation/`.
  - `data/repositories/` — Implementations of `domain/` repository interfaces.
  - `presentation/` — Riverpod providers/notifiers, screens, and module-specific widgets.
- **Dependency Flow:** `presentation` -> `domain` / `core/common/entities` <- `data`. Never import `data` directly inside `presentation`.

## Node Connection Isolation (Local vs. Cloud Nodes)
- **Keep Local Nodes and Cloud Nodes completely separated** across domain models/use cases, data sources, and connection flows:
  - **Local Nodes** (user-imported / manual configs): Connect directly using local config parsing and local storage without requiring Appwrite device attestation, cloud provisioning, or cloud quota deduction.
  - **Cloud Nodes** (managed Appwrite / 3x-ui nodes): Must go through the cloud provisioning/attestation and quota-gated connection pipeline.
- Never tangle local-node and cloud-node branching inside `Widget.build()` or inside a single monolithic datasource method—use separate use cases / strategy implementations behind a clean domain contract.

## Quota Architecture (Future Backend Migration Ready)
- **Decouple Quota Logic from UI & Other Features:** Currently quota usage is tracked/reported by the client to Appwrite, but it will soon move completely server-side (3x-ui / backend metering).
- Expose quota state to `presentation/` and other modules **exclusively** through a domain `QuotaRepository` interface and a pure `QuotaEntity` (`usedBytes`, `totalBytes`, `bonusBytes`, `isExhausted`) in `lib/core/common/entities/`.
- Encapsulate how usage is calculated, synced, or polled strictly inside `data/datasources/` and `data/repositories/` so switching from client-side calculation to backend-authoritative polling requires **zero changes** to UI widgets, AdMob reward handlers, or VPN connection screens.

## State Management & DI
- Use **Riverpod** with `@riverpod` code generation (`riverpod_annotation`) and `GetIt` / `GoRouter` as configured in the project.
- Riverpod notifiers depend only on `domain/` repositories or use cases—never directly on `data/datasources/` or ad/VPN SDK classes.
- After modifying any `@riverpod` provider, run:
  `dart run build_runner build --delete-conflicting-outputs`
- Keep business logic and Appwrite/Xray calls inside Riverpod notifiers or domain use cases—never inside `Widget.build()`.

## Theme & Styling (`Pallet`)
- Use explicit light/dark color tokens defined in the project's `Pallet` / `ThemeExtension` classes.
- Never hardcode `Color(0x...)` or `Colors.*` values inside screens or reusable widgets.

## Widget Extraction & UI Rules
- Keep screen `build()` methods concise (< ~150 lines) and declarative.
- Extract repeated cards, status indicators, buttons, and quota/stat tiles into `const` `StatelessWidget` classes under `lib/core/widgets/` or `lib/src/.../presentation/widgets/`.
- **No `Widget _build...()` helper methods** for complex UI blocks; prefer `StatelessWidget` classes so Flutter's element tree skips unnecessary rebuilds during live traffic/timer ticks.
- Generic widgets in `lib/core/widgets/` must remain dumb: accept typed values and callbacks (`VoidCallback`) rather than reading Riverpod providers directly.

## Local `flutter_v2ray_client` Plugin (CRITICAL)
- This repo uses a modified local/overridden `flutter_v2ray_client` plugin that includes custom native iOS proxy-only Xray support while preserving a unified Dart API across Android and iOS.
- **Do NOT overwrite, reset, or break** the unified Dart interface or native iOS/Android modifications inside the local `flutter_v2ray_client` plugin when refactoring or running dependency updates.

## Security, Config & Release Hygiene
- Public repository: **never commit** production AdMob IDs, Google Cloud project numbers, server IPs, or signing files (`key.properties`, `*.jks`).
- Load environment values via `String.fromEnvironment` in `AppConfig` (`APPWRITE_ENDPOINT`, `APPWRITE_PROJECT_ID`, `GCP_PROJECT_NUMBER`, `ADMOB_REWARDED_ID`, `ADMOB_INTERSTITIAL_ID`), using Google sample ad IDs only when `kDebugMode` is true.
- Ad loading (rewarded and interstitial) must fail gracefully on `No Fill`—never block VPN connection if an ad fails to load.
- Gate debug logs behind `kDebugMode`; avoid raw `print()` in production code.

## Verification Commands
- Analyze: `flutter analyze`
- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Tests: `flutter test`