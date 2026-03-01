#!/usr/bin/env python3
"""Fetch UPSC-relevant current affairs from RSS feeds and push to backend.

Usage:
  python rss_ingest.py --out current_affairs.json
  python rss_ingest.py --api-base https://your-api.example.com --api-key <token>
"""

from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Iterable

import feedparser
import requests
from bs4 import BeautifulSoup
from dateutil import parser as date_parser


DEFAULT_FEEDS = [
    "https://www.insightsonindia.com/feed/",
    "https://www.drishtiias.com/rss-feed",
    "https://www.visionias.in/feed",
    "https://www.pmfias.com/feed/",
    "https://vajiramandravi.com/feed/",
    "https://www.clearias.com/feed/",
]

TAG_RULES = {
    "polity": "Polity",
    "economy": "Economy",
    "budget": "Economy",
    "inflation": "Economy",
    "environment": "Environment",
    "climate": "Environment",
    "ecology": "Environment",
    "international": "IR",
    "foreign": "IR",
    "defence": "Security",
    "science": "Science & Tech",
    "technology": "Science & Tech",
    "governance": "Governance",
}


@dataclass(frozen=True)
class CurrentAffair:
    id: str
    title: str
    summary: str
    date: str
    tags: list[str]
    facts: list[str]
    source_name: str
    source_url: str

    def to_json(self) -> dict:
        return {
            "id": self.id,
            "title": self.title,
            "summary": self.summary,
            "date": self.date,
            "tags": self.tags,
            "facts": self.facts,
            "sourceName": self.source_name,
            "sourceUrl": self.source_url,
        }


def clean_html(text: str) -> str:
    return BeautifulSoup(text or "", "html.parser").get_text(" ", strip=True)


def infer_tags(title: str, summary: str) -> list[str]:
    haystack = f"{title} {summary}".lower()
    tags = {label for key, label in TAG_RULES.items() if key in haystack}
    return sorted(tags) if tags else ["Current Affairs"]


def top_facts(summary: str, max_count: int = 3) -> list[str]:
    chunks = [s.strip() for s in summary.replace(";", ".").split(".") if s.strip()]
    return chunks[:max_count] if chunks else ["Read full article for details"]


def parse_date(entry: dict) -> datetime:
    candidate = entry.get("published") or entry.get("updated")
    if not candidate:
        return datetime.now(timezone.utc)
    try:
        dt = date_parser.parse(candidate)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)
    except Exception:
        return datetime.now(timezone.utc)


def build_id(url: str, title: str) -> str:
    raw = f"{url}|{title}".encode("utf-8")
    return hashlib.sha1(raw).hexdigest()[:16]


def read_feeds(feed_urls: Iterable[str], limit_per_feed: int) -> list[CurrentAffair]:
    items: list[CurrentAffair] = []
    seen_ids: set[str] = set()

    for url in feed_urls:
        parsed = feedparser.parse(url)
        source_name = parsed.feed.get("title", url)

        for entry in parsed.entries[:limit_per_feed]:
            title = clean_html(entry.get("title", "Untitled"))
            link = entry.get("link", "")
            summary = clean_html(entry.get("summary", ""))
            summary = summary[:700] if len(summary) > 700 else summary

            uid = build_id(link, title)
            if uid in seen_ids:
                continue
            seen_ids.add(uid)

            published_at = parse_date(entry).isoformat()
            tags = infer_tags(title, summary)
            facts = top_facts(summary)

            items.append(
                CurrentAffair(
                    id=uid,
                    title=title,
                    summary=summary,
                    date=published_at,
                    tags=tags,
                    facts=facts,
                    source_name=source_name,
                    source_url=link,
                )
            )

    items.sort(key=lambda i: i.date, reverse=True)
    return items


def push_to_api(base_url: str, api_key: str, items: list[CurrentAffair]) -> None:
    endpoint = f"{base_url.rstrip('/')}/ingest/current-affairs"
    payload = {"items": [i.to_json() for i in items]}
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    response = requests.post(endpoint, headers=headers, json=payload, timeout=30)
    response.raise_for_status()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--feed", action="append", default=[])
    parser.add_argument("--limit-per-feed", type=int, default=20)
    parser.add_argument("--out", default="")
    parser.add_argument("--api-base", default="")
    parser.add_argument("--api-key", default="")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    feeds = args.feed if args.feed else DEFAULT_FEEDS
    items = read_feeds(feeds, args.limit_per_feed)

    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            json.dump([i.to_json() for i in items], f, indent=2)

    if args.api_base and args.api_key:
        push_to_api(args.api_base, args.api_key, items)

    print(f"Fetched {len(items)} current-affairs items")


if __name__ == "__main__":
    main()
