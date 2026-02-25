# Complete App Architecture

## 1) Architecture Style

- Pattern: Clean Architecture + feature-first modules
- State management: Riverpod (`Provider`, `StateProvider`, `FutureProvider`)
- Navigation: GoRouter with ShellRoute + bottom navigation
- Data: Repository pattern with local-first reads and remote sync

Layers per feature:
- `domain`: entities + use-case contracts
- `data`: repository implementations and data-source adapters
- `presentation`: screens, view state providers, UI widgets

## 2) Screen List + Navigation Flow

Primary routes:
- `/login`
- `/dashboard`
- `/subjects`
- `/subjects/topic/:topicId`
- `/practice/mcq`
- `/practice/mock`
- `/pyq`
- `/current-affairs`
- `/ai`
- `/analytics`

Flow:
1. Login -> Dashboard
2. Dashboard quick actions -> Subjects/MCQ/PYQ/Current Affairs
3. Subject tree -> topic details with notes and revision metadata
4. Practice routes -> MCQ + mock test analysis
5. AI and Analytics tabs for updates + progress

## 3) UI Design System

- Material 3 with adaptive density
- Cupertino typography override for iOS-like feel
- Minimal palette from teal seed (`0xFF0E7490`)
- Large touch targets via `NavigationBar`, `FilledButton`, spacious cards
- Dark mode via `ThemeMode.system`
- Focus mode banner and toggles
- Tablet support with constrained auth form and adaptive list/card layout

## 4) Flutter Folder Structure

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    constants/
    network/
    security/
    storage/
    sync/
    utils/
  features/
    auth/
    dashboard/
    subjects/
    mcq/
    pyq/
    current_affairs/
    ai/
    analytics/
  shared/widgets/
```

## 5) Offline-First + Sync

- Read path: local cache (Hive) -> fallback remote
- Write path: local write-through + async remote sync queue
- Sync cadence:
  - daily current affairs
  - AI suggestion pull
  - revision queue updates
- Conflict policy: last-write-wins for user flags; versioned merge for content

## 6) Privacy + Private Setup

- Private login flow
- No ad SDK integrations
- `publish_to: none`
- Token storage with `flutter_secure_storage`
- Recommended:
  - API auth with short-lived JWT + refresh token
  - local DB encryption key kept in secure storage
  - private distribution via TestFlight/internal Play track/enterprise MDM

## 7) Performance Optimization

- Pagination on feed-heavy screens (current affairs, PYQ)
- Debounced filters and local index tables
- lazy builders (`ListView.builder`) for large datasets
- background prefetch of next content batch
- compressed image/PDF metadata-only preload

## 8) Backup + Multi-device Sync

- Option A: User cloud backup (Drive/iCloud file export encrypted)
- Option B: API-backed account sync with per-device delta sync
- Backup job policy:
  - nightly encrypted snapshot
  - restore checksum validation

## 9) Future Features

- Voice notes linked to topic/chapter
- Doubt solving inbox with AI-first and mentor escalation
- Smart revision planner (SM-2 or Leitner)
- Daily target planner with time-boxing and adaptive goals
