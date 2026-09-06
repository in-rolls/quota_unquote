#!/usr/bin/env python3
"""Fetch the PAI Good Governance (theme 8) indicator lists from the PAI portal.

Output: docs/pai_theme8_indicators.csv, one row per indicator and PAI version,
with the column contract in `INDICATOR_DTYPES` and the checks in `validate()`.
"""

from __future__ import annotations

import argparse
import datetime as dt
import html
import http.cookiejar
import re
import urllib.request
from collections.abc import Callable
from pathlib import Path
from typing import Any

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[1]
OUTPUT = PROJECT_ROOT / "docs" / "pai_theme8_indicators.csv"
PORTAL = "https://pai.gov.in/MMS/Indicator/Theme-Indicators.aspx"
THEME = 8
VERSIONS = {1: ("PAI 1.0", "2022-2023"), 2: ("PAI 2.0", "2023-2024")}
EXPECTED_INDICATORS = {"PAI 1.0": 62, "PAI 2.0": 26}
EXPECTED_SHARED_IDS = 10

INDICATOR_DTYPES: dict[str, Any] = {
    "pai_version": "string",
    "fiscal_year": "string",
    "indicator_id": "int64",
    "mandatory": "string",
    "kind": "string",
    "indicator": "string",
    "numerator": "string",
    "denominator": "string",
    "source_url": "string",
    "retrieved_utc": "string",
}
KEY = ["pai_version", "indicator_id"]
KINDS = {"ratio", "number", "binary"}
NUMERIC_LABEL = re.compile(
    r"^(number of|no\. of|total |percentage|share of|ratio of|rate of"
    r"|drop-?out rate|average)",
    re.I,
)
MANDATORY = {"Mandatory", "Optional"}

ID_SUFFIX = re.compile(r"\s*\[(\d+)\]\s*$")
ROW = re.compile(r"<tr>(.*?)</tr>", re.S)
CELL = re.compile(r"<td[^>]*>(.*?)</td>", re.S)
TAG = re.compile(r"<[^>]+>")


# The portal renders the PAI 1.0 table only once a session cookie exists, so the
# PAI 2.0 page is requested first through a cookie-carrying opener.
FETCH_ORDER = (2, 1)


def fetch(session_id: int, opener: urllib.request.OpenerDirector) -> str:
    """Return the indicator page for one PAI version."""
    url = f"{PORTAL}?t={THEME}&s={session_id}"
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with opener.open(request, timeout=60) as response:
        return response.read().decode("utf-8", errors="replace")


def fetch_pages(
    opener: urllib.request.OpenerDirector, fetch_one: Callable[..., str] = fetch
) -> dict[int, str]:
    """Fetch every version's page in `FETCH_ORDER`, sharing one session."""
    if set(FETCH_ORDER) != set(VERSIONS):
        raise ValueError("FETCH_ORDER must cover every version")
    return {session_id: fetch_one(session_id, opener) for session_id in FETCH_ORDER}


def _text(cell: str) -> str:
    return re.sub(r"\s+", " ", html.unescape(TAG.sub("", cell))).strip()


def parse(page: str) -> list[tuple[str, str, str, str]]:
    """Return (mandatory, indicator, numerator, denominator) per table row."""
    rows = []
    for row in ROW.findall(page):
        cells = [_text(cell) for cell in CELL.findall(row)]
        if len(cells) == 5:
            rows.append((cells[1], cells[2], cells[3], cells[4]))
    return rows


def classify(indicator: str, numerator: str, denominator: str) -> str:
    """Ratio: a denominator distinct from the numerator. Number: a single reported
    quantity. Binary: everything else, a yes/no wording on the portal. The kind
    follows the portal's data columns, not the label wording."""
    if denominator and denominator.lower() != numerator.lower():
        return "ratio"
    if NUMERIC_LABEL.match(indicator):
        return "number"
    return "binary"


def build(pages: dict[int, str], retrieved_utc: str) -> pd.DataFrame:
    records = []
    for session_id, page in pages.items():
        version, fiscal_year = VERSIONS[session_id]
        seen: set[int] = set()
        for mandatory, indicator, numerator, denominator in parse(page):
            match = ID_SUFFIX.search(indicator)
            if match is None:
                raise ValueError(f"{version}: indicator without an id: {indicator!r}")
            indicator_id = int(match.group(1))
            # The portal repeats an indicator under alias wordings; the id is the key.
            if indicator_id in seen:
                continue
            seen.add(indicator_id)
            name = ID_SUFFIX.sub("", indicator)
            numerator_text = ID_SUFFIX.sub("", numerator)
            denominator_text = ID_SUFFIX.sub("", denominator)
            records.append(
                {
                    "pai_version": version,
                    "fiscal_year": fiscal_year,
                    "indicator_id": indicator_id,
                    "mandatory": mandatory,
                    "kind": classify(name, numerator_text, denominator_text),
                    "indicator": name,
                    "numerator": numerator_text,
                    "denominator": denominator_text,
                    "source_url": f"{PORTAL}?t={THEME}&s={session_id}",
                    "retrieved_utc": retrieved_utc,
                }
            )
    frame = pd.DataFrame.from_records(records).astype(INDICATOR_DTYPES)
    return frame.sort_values(KEY, ignore_index=True)


def validate(frame: pd.DataFrame) -> pd.DataFrame:
    """Raise unless the table meets the documented contract; return it unchanged."""
    if list(frame.columns) != list(INDICATOR_DTYPES):
        raise ValueError(f"Unexpected columns: {list(frame.columns)}")
    for column, dtype in INDICATOR_DTYPES.items():
        if str(frame[column].dtype) != dtype:
            raise ValueError(f"{column} is {frame[column].dtype}, expected {dtype}")
    if frame.duplicated(KEY).any():
        raise ValueError("(pai_version, indicator_id) is not unique")
    if frame.isna().to_numpy().any():
        raise ValueError("Missing values are not allowed")
    required = ["indicator", "numerator", "source_url", "retrieved_utc"]
    if frame[required].eq("").to_numpy().any():
        raise ValueError(f"{required} must be filled")
    if not set(frame["kind"]) <= KINDS:
        raise ValueError(f"kind outside {sorted(KINDS)}")
    if not set(frame["mandatory"]) <= MANDATORY:
        raise ValueError(f"mandatory outside {sorted(MANDATORY)}")
    if (frame.loc[frame["kind"] == "ratio", "denominator"] == "").any():
        raise ValueError("A ratio indicator lacks a denominator")
    versions = set(frame["pai_version"])
    if versions != set(EXPECTED_INDICATORS):
        raise ValueError(f"Versions {sorted(versions)} differ from the contract")
    counts = frame.groupby("pai_version").size().to_dict()
    if counts != EXPECTED_INDICATORS:
        raise ValueError(f"Indicator counts {counts} differ from {EXPECTED_INDICATORS}")
    ids = {v: set(g["indicator_id"]) for v, g in frame.groupby("pai_version")}
    shared = len(ids["PAI 1.0"] & ids["PAI 2.0"])
    if shared != EXPECTED_SHARED_IDS:
        raise ValueError(
            f"{shared} shared indicator ids, expected {EXPECTED_SHARED_IDS}"
        )
    for column in ("fiscal_year", "source_url"):
        if bool(frame.groupby("pai_version")[column].nunique().ne(1).any()):
            raise ValueError(f"{column} must be constant within a version")
    return frame


def read(path: Path = OUTPUT) -> pd.DataFrame:
    return validate(pd.read_csv(path, dtype=INDICATOR_DTYPES, keep_default_na=False))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    args = parser.parse_args()

    opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar())
    )
    retrieved = dt.datetime.now(dt.UTC).strftime("%Y-%m-%dT%H:%M:%SZ")
    pages = fetch_pages(opener)
    frame = validate(build(pages, retrieved))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    frame.to_csv(args.output, index=False)
    summary = frame.groupby(["pai_version", "kind"]).size()
    print(summary.to_string())
    print(f"Wrote {len(frame)} rows to {args.output}")


if __name__ == "__main__":
    main()
