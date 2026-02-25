# API Contracts

Base path: `/v1`
Auth: Bearer JWT

## Auth

### `POST /auth/login`
Request:
```json
{ "email": "user@example.com", "password": "secret" }
```
Response:
```json
{ "accessToken": "...", "refreshToken": "...", "expiresIn": 3600 }
```

## Syllabus + Notes

### `GET /subjects`
Response:
```json
{ "items": [{ "id": "polity", "name": "Indian Polity", "version": 3 }] }
```

### `GET /subjects/{subjectId}/chapters`
### `GET /chapters/{chapterId}/topics`
### `GET /topics/{topicId}`

## MCQ + Mock

### `GET /mcq/questions?subject=&chapter=&difficulty=&page=`
### `POST /mcq/attempts`
Request:
```json
{
  "questionSetId": "set-123",
  "answers": [{ "questionId": "m1", "selected": 2, "seconds": 48 }]
}
```
Response:
```json
{ "score": 71, "accuracy": 71.0, "weakAreas": ["Parliament", "Inflation"] }
```

## PYQ

### `GET /pyq?year=&subject=&chapter=&topic=&page=`
### `POST /pyq/attempts`

## Current Affairs

### `GET /current-affairs/daily?date=YYYY-MM-DD`
### `GET /current-affairs/monthly?month=YYYY-MM`
### `POST /current-affairs/actions`
Request:
```json
{ "itemId": "ca1", "bookmark": true, "reviseLater": true }
```

## AI Endpoints

### `POST /ai/summarize`
### `POST /ai/generate-mcq`
### `POST /ai/revision-questions`
### `GET /ai/updates?cursor=`

AI update response:
```json
{
  "items": [
    {
      "id": "ai1",
      "type": "summary",
      "title": "Daily UPSC Summary",
      "content": "...",
      "createdAt": "2026-02-25T15:30:00Z"
    }
  ],
  "nextCursor": "abc"
}
```

## Analytics

### `GET /analytics/overview`
Response includes:
- studyMinutes
- streakDays
- weeklyProgress
- subjectStrength map
- pyqCoverage
- mockTrend list
