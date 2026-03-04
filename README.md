# UPSC Prep Pro (Flutter)

Private, offline-first UPSC preparation app starter with:
- Prelims, Mains, Current Affairs, PYQs, MCQs, Mock Tests
- AI-assisted content updates pipeline interfaces
- Dashboard analytics
- Clean Architecture + Riverpod + GoRouter + Hive

## Quick Start

```bash
flutter pub get
flutter run
```

Entry route is `/login`, then dashboard with modular navigation.

## Firestore Setup

This app now supports:
- Firestore for dynamic content (`current_affairs` collection)
- Local bundled PYQ data (offline-first)
- Automatic fallback to local repositories when remote sources fail

Use `--dart-define` values to enable production data.

If `android/app/google-services.json` (and/or iOS `GoogleService-Info.plist`) is present, you only need:

```bash
flutter run --dart-define=ENABLE_FIRESTORE_CURRENT_AFFAIRS=true
```

If you prefer runtime env configuration without native config files, use:

```bash
flutter run \
  --dart-define=ENABLE_FIRESTORE_CURRENT_AFFAIRS=true \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=...
```

## Implemented Starter Modules

- Authentication (private login shell)
- Dashboard and focus mode
- Subjects -> Chapters -> Topics -> Notes
- Topic notes with important points, references, PDF link slot, bookmark/highlight actions
- MCQ practice, timed mode toggle, explanation display
- Mock test history with weak-area analysis placeholder
- PYQ browser with tags (topic, difficulty, static/current)
- Current affairs daily feed + bookmark + revise later + offline cache intent
- AI update center (summary, MCQ generation, note conversion, revision notes)
- Analytics dashboard with score chart and readiness metrics

## Documentation

- [Architecture](./docs/architecture.md)
- [UI Wireframes](./docs/ui_wireframes.md)
- [Database Schema](./docs/database_schema.md)
- [API Contracts](./docs/api_contracts.md)
- [Content & CMS Plan](./docs/content_management.md)
- [Testing Strategy](./docs/testing_strategy.md)
- [Development Roadmap](./docs/development_roadmap.md)

## Suggested Next Build Steps

1. Replace demo repositories with real API + local storage adapters.
2. Add robust auth/session refresh + encrypted keys.
3. Add background tasks (`workmanager`) for daily content sync.
4. Integrate AI service endpoint and queue-based generation.
5. Add full test suite + CI.
