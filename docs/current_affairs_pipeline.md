# Current Affairs Auto-Update Pipeline

## Recommended Architecture
1. `Scraper job` (Python) runs every 6 hours.
2. Job ingests RSS feeds from UPSC sources and normalizes records.
3. Normalized data is pushed to your backend endpoint.
4. Backend stores items in DB and serves API.
5. Flutter app fetches from API with offline fallback.

## Why this is better
- No scraping from mobile app.
- Centralized cleaning/tagging.
- Easy retries and monitoring.
- Lower app latency and better reliability.

## Script included
Use:
- `tools/current_affairs/rss_ingest.py`
- `tools/current_affairs/requirements.txt`

Run locally:
```bash
pip install -r tools/current_affairs/requirements.txt
python tools/current_affairs/rss_ingest.py --out /tmp/current_affairs.json
```

Push to backend:
```bash
python tools/current_affairs/rss_ingest.py \
  --api-base https://your-api.example.com \
  --api-key YOUR_SECRET_TOKEN
```

## API Contract (Backend)
### Ingest endpoint
- `POST /ingest/current-affairs`
- Header: `Authorization: Bearer <token>`
- Body:
```json
{
  "items": [
    {
      "id": "string",
      "title": "string",
      "summary": "string",
      "date": "ISO8601",
      "tags": ["Economy"],
      "facts": ["fact1", "fact2"],
      "sourceName": "Insights IAS",
      "sourceUrl": "https://..."
    }
  ]
}
```

### App fetch endpoint
- `GET /current-affairs/daily`
- Response:
```json
[
  {
    "id": "string",
    "title": "string",
    "summary": "string",
    "date": "ISO8601",
    "tags": ["Polity"],
    "facts": ["..."]
  }
]
```

## Flutter Integration
App supports remote fetch via Dart define:
```bash
flutter run --dart-define=CURRENT_AFFAIRS_API_BASE_URL=https://your-api.example.com
```
If API fails, app falls back to local demo data.
