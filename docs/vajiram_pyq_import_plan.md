# Vajiram PYQ Import Plan (2014-2025)

Current app supports full local DB storage and year-wise GS/CSAT test routing.

## To load exact real-paper questions

1. Download yearly PDFs (GS + CSAT) from Vajiram previous papers page.
2. Place files in a local folder (example):
   - `assets/pyq_pdfs/2014_gs.pdf`
   - `assets/pyq_pdfs/2014_csat.pdf`
   - ... up to 2025.
3. Extract question text/options/correct answers to JSON using a parser/OCR pipeline.
4. Import JSON into Hive `pyq_bank_box` with schema from `PyqQuestion.toMap()`.

## Why this step is required

PDF scraping/extraction quality varies by layout and scan quality. Reliable exam-grade accuracy needs parser validation before inserting into final local DB.
