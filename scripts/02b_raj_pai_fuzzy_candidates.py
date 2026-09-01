#!/usr/bin/env python3
"""Propose PAI 2.0 GP links inside approved district-block groups.

Outputs are review queues only. This script never edits the active crosswalk.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SIBLING_PRECLINK = PROJECT_ROOT.parent / "preclink" / "src"
if SIBLING_PRECLINK.is_dir():
    sys.path.insert(0, str(SIBLING_PRECLINK))

from preclink import Pipeline, StringComparison  # noqa: E402


def propose_links(left: pd.DataFrame, right: pd.DataFrame):
    """Return a precision-first linkage result for normalized GP names."""
    required_left = {"election_gp_key", "canonical_group", "gp_name"}
    required_right = {"pai_row_key", "canonical_group", "gp_name"}
    if not required_left.issubset(left.columns):
        raise ValueError(
            f"Left input lacks {sorted(required_left - set(left.columns))}"
        )
    if not required_right.issubset(right.columns):
        raise ValueError(
            f"Right input lacks {sorted(required_right - set(right.columns))}"
        )
    if left["election_gp_key"].duplicated().any():
        raise ValueError("election_gp_key is not unique")
    if right["pai_row_key"].duplicated().any():
        raise ValueError("pai_row_key is not unique")

    return (
        Pipeline()
        .block(on="canonical_group")
        .score([StringComparison("gp_name", algorithm="jaro_winkler")])
        .filter(min_score=0.85, margin=0.05)
        .decide(method="hungarian")
        .build()
        .link(left, right)
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Create a blinded PAI 2.0 fuzzy-link review queue"
    )
    parser.add_argument(
        "--left",
        type=Path,
        default=PROJECT_ROOT / "data/crosswalks/audit/pai2_unmatched_left.parquet",
    )
    parser.add_argument(
        "--right",
        type=Path,
        default=PROJECT_ROOT / "data/crosswalks/audit/pai2_unmatched_right.parquet",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=PROJECT_ROOT / "data/crosswalks/audit",
    )
    args = parser.parse_args()

    left = pd.read_parquet(args.left)
    right = pd.read_parquet(args.right)
    result = propose_links(left, right)

    args.out_dir.mkdir(parents=True, exist_ok=True)
    candidate_path = args.out_dir / "pai2_gp_candidate_pairs.parquet"
    filtered_path = args.out_dir / "pai2_gp_filtered_pairs.parquet"
    proposal_path = args.out_dir / "pai2_gp_review_queue.csv"

    result.candidate_pairs.to_parquet(candidate_path, index=False)
    result.filtered_pairs.to_parquet(filtered_path, index=False)

    proposal_columns = [
        "election_gp_key",
        "pai_row_key",
        "canonical_group_left",
        "gp_name_left",
        "gp_name_right",
        "raw_district",
        "raw_block",
        "raw_gp_name",
        "pai_district",
        "pai_block",
        "pai_gp_name",
        "gp_name_score",
        "score",
    ]
    proposals = result.matches.loc[:, proposal_columns].copy()
    proposals["decision"] = ""
    proposals["reviewer"] = ""
    proposals["reviewed_at"] = ""
    proposals["notes"] = ""
    proposals.to_csv(proposal_path, index=False)

    print(f"Candidate pairs: {len(result.candidate_pairs):,} -> {candidate_path}")
    print(f"Filtered pairs: {len(result.filtered_pairs):,} -> {filtered_path}")
    print(f"Proposed 1:1 links: {len(proposals):,} -> {proposal_path}")


if __name__ == "__main__":
    main()
