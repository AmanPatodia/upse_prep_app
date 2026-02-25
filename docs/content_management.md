# Data Collection & Content Management Plan

## 1) UPSC Syllabus Collection

- Source official UPSC notifications and syllabus PDFs.
- Normalize into: `subject -> chapter -> topic -> subtopic`.
- Maintain source reference metadata for traceability.

## 2) Notes Structuring

Per topic store:
- concise summary
- important points
- mains angle
- prelims facts
- references (book/chapter/page)
- revision priority

## 3) MCQ Storage Strategy

Each MCQ includes:
- subject/chapter/topic tags
- difficulty
- explanation
- source attribution
- static/current classification

## 4) Daily Current Affairs Workflow

1. Ingest trusted sources feed.
2. Deduplicate by headline/topic/date hash.
3. AI summary -> UPSC note format.
4. Editorial review queue.
5. Publish to `/current-affairs/daily`.
6. Auto-generate monthly compilation.

## 5) PYQ Tagging

For each PYQ:
- year
- exam stage (Prelims/Mains)
- subject/chapter/topic
- difficulty
- static/current linkage
- explanation + learning objective

## 6) Content Versioning

- global content snapshot version per release
- per-entity `contentVersion`
- maintain changelog table with rollback point

## 7) Optional Private CMS Design

Roles:
- Admin: publish/version rollback
- Editor: add/edit notes/questions
- Reviewer: approve quality checks

Core CMS modules:
- Topic editor
- MCQ/PYQ editor with bulk import CSV
- Current affairs ingestion + AI draft review
- Release manager (staging -> publish)
