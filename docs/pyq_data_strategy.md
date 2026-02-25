# PYQ Data Strategy (Source-aligned)

## Target Sources

- UPSC official previous year papers (primary source)
- Drishti IAS
- ForumIAS
- Insights IAS
- PMF IAS
- Vision IAS

## Recommended Collection Pipeline

1. Use UPSC official PDFs as source-of-truth for question text.
2. Use coaching sources for explanations, topic tags, and difficulty calibration.
3. Run deduplication by question text hash + year.
4. Editorial validation before publishing to production dataset.

## In-App Data Model Support

Current app supports:
- year-wise metadata
- subject/chapter/topic tags
- static/current linkage
- explanation for every question
- full test generation (100-question format)
- attempt history and analytics

## Legal/Practical Note

Some source content can be copyrighted or behind paywalls. Use official papers as base and store only licensed/owned explanation text in production.
