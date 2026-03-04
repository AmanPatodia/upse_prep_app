#!/usr/bin/env python3
"""Bulk ingest current affairs into Firestore from a JSON file.

Example:
  python tools/current_affairs/firestore_ingest.py \
    --service-account /path/to/service-account.json \
    --from-json /tmp/current_affairs.json \
    --delete-source-on-success
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from datetime import datetime, timezone
from typing import Iterable

import firebase_admin
from firebase_admin import credentials, firestore
from dateutil import parser as date_parser


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--service-account", required=True)
    parser.add_argument("--project-id", default="")
    parser.add_argument("--collection", default="current_affairs")
    parser.add_argument("--from-json", required=True)
    parser.add_argument("--batch-size", type=int, default=400)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--delete-source-on-success", action="store_true")
    return parser.parse_args()


def load_items(args: argparse.Namespace) -> list[dict]:
    with open(args.from_json, "r", encoding="utf-8") as f:
        data = json.load(f)
    if isinstance(data, dict):
        return [data]
    if isinstance(data, list):
        return [d for d in data if isinstance(d, dict)]
    raise ValueError("--from-json must contain a JSON object or JSON array")


def parse_iso_to_datetime(value: str | None) -> datetime:
    if not value:
        return datetime.now(timezone.utc)
    try:
        dt = date_parser.parse(value)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)
    except Exception:
        return datetime.now(timezone.utc)


def normalize_item(raw: dict) -> dict:
    item_id = str(raw.get("id", "")).strip()
    title = str(raw.get("title", "")).strip()
    if not title:
        raise ValueError("Each item must have non-empty title")
    if not item_id:
        seed = f"{title}|{raw.get('date', '')}".encode("utf-8")
        item_id = hashlib.sha1(seed).hexdigest()[:16]

    summary = str(raw.get("summary", "")).strip()
    in_brief = str(raw.get("inBrief", summary)).strip() or summary

    tags_raw = raw.get("tags", [])
    tags = [str(t).strip() for t in tags_raw if str(t).strip()] if isinstance(tags_raw, list) else []

    facts_raw = raw.get("facts", raw.get("keyPoints", []))
    facts = [str(f).strip() for f in facts_raw if str(f).strip()] if isinstance(facts_raw, list) else []

    source_name = str(raw.get("sourceName", "")).strip()
    source_url = str(raw.get("sourceUrl", "")).strip()

    date_value = parse_iso_to_datetime(str(raw.get("date", "")).strip())

    return {
        "id": item_id,
        "title": title,
        "summary": summary,
        "inBrief": in_brief,
        "date": date_value,
        "tags": tags,
        "facts": facts,
        "keyPoints": facts,
        "sourceName": source_name,
        "sourceUrl": source_url,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }


def chunks(items: list[dict], size: int) -> Iterable[list[dict]]:
    for i in range(0, len(items), size):
        yield items[i : i + size]


def init_firestore(service_account_path: str, project_id: str):
    cred = credentials.Certificate(service_account_path)
    if project_id.strip():
        app = firebase_admin.initialize_app(cred, {"projectId": project_id.strip()})
    else:
        app = firebase_admin.initialize_app(cred)
    return firestore.client(app=app)


def main() -> None:
    args = parse_args()
    if args.batch_size <= 0 or args.batch_size > 500:
        raise ValueError("--batch-size must be between 1 and 500")

    raw_items = load_items(args)
    cleaned = []
    skipped = 0
    for row in raw_items:
        try:
            cleaned.append(normalize_item(row))
        except Exception:
            skipped += 1

    print(f"Prepared {len(cleaned)} items (skipped={skipped})")
    if args.dry_run:
        print("Dry run enabled. No writes performed.")
        return

    db = init_firestore(args.service_account, args.project_id)
    collection = db.collection(args.collection)
    written = 0

    for group in chunks(cleaned, args.batch_size):
        batch = db.batch()
        for item in group:
            doc_ref = collection.document(item["id"])
            batch.set(doc_ref, item, merge=True)
        batch.commit()
        written += len(group)
        print(f"Committed {written}/{len(cleaned)}")

    print(f"Done. Wrote {written} documents to '{args.collection}'.")
    if args.delete_source_on_success:
        os.remove(args.from_json)
        print(f"Deleted source file: {args.from_json}")


if __name__ == "__main__":
    main()
