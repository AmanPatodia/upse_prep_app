# Current Affairs Data Flow (Firestore Only)

## Source of truth
- Firestore collection: `current_affairs`
- Manual entry by admin in Firebase Console

## App behavior
1. App reads Firestore items ordered by `date` (latest first).
2. App stores fetched items in Hive cache (`current_affairs_box`).
3. On next app open:
   - If cache is fresh, app shows Hive data immediately.
   - If cache is stale, app refreshes from Firestore and updates Hive.
   - If Firestore fails, app falls back to Hive cache.

## Required Firestore fields per document
- `id` (string; optional, doc id used if missing)
- `title` (string)
- `date` (Timestamp)
- `summary` or `inBrief` (string)
- `facts` or `keyPoints` (array of string)
- `tags` (array of string)
- `sourceName` (string)
- `sourceUrl` (string)

## JSON ingest helper
You can ingest from:
- A single JSON object (one topic)
- A JSON array (multiple topics for a day)

Command:
```bash
python tools/current_affairs/firestore_ingest.py \
  --service-account /absolute/path/to/firebase-service-account.json \
  --from-json /absolute/path/to/current_affairs.json
```

## Run command
```bash
flutter run --dart-define=ENABLE_FIRESTORE_CURRENT_AFFAIRS=true
```
