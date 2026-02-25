# Database Schema (Hive-first, Isar/Drift migration-ready)

## Boxes

- `subjects_box`
- `mcq_attempts_box`
- `pyq_attempts_box`
- `current_affairs_box`
- `bookmarks_box`
- `settings_box`

## Suggested Entity Structures

## `subjects`
- `id` (string, pk)
- `name` (string)
- `version` (int)
- `updatedAt` (datetime)

## `chapters`
- `id` (string, pk)
- `subjectId` (string, indexed)
- `title` (string)
- `sortOrder` (int)

## `topics`
- `id` (string, pk)
- `chapterId` (string, indexed)
- `title` (string)
- `notes` (text)
- `importantPoints` (json array)
- `bookReferences` (json array)
- `pdfUrl` (string?)
- `imageUrls` (json array)
- `revisionPriority` (enum)
- `isBookmarked` (bool)
- `isHighlighted` (bool)
- `contentVersion` (int)

## `mcq_questions`
- `id` (string, pk)
- `subject`, `chapter`, `topicTag` (indexed)
- `difficulty` (enum)
- `question` (text)
- `options` (json array)
- `correctIndex` (int)
- `explanation` (text)

## `mcq_attempts`
- `id` (string, pk)
- `questionSetId` (string)
- `total`, `correct` (int)
- `avgSecondsPerQuestion` (double)
- `submittedAt` (datetime)

## `pyq_questions`
- `id` (string, pk)
- `year` (int, indexed)
- `subject`, `chapter`, `topicTag` (indexed)
- `difficulty` (enum)
- `isCurrentAffairsLinked` (bool)
- `question/options/correctIndex/explanation`

## `current_affairs`
- `id` (string, pk)
- `date` (datetime, indexed)
- `title`, `summary`
- `tags` (json array, indexed via helper table if needed)
- `facts` (json array)
- `isBookmarked` (bool)
- `reviseLater` (bool)

## `sync_state`
- `id` (string, pk)
- `contentType` (string)
- `lastSyncAt` (datetime)
- `etag` (string?)
- `cursor` (string?)

## Content Versioning Strategy

- Every content row stores `contentVersion`.
- API sends `version` and `delta` payload.
- Local applies patch if server version > local version.
