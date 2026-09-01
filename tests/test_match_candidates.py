from __future__ import annotations

import importlib.util
from pathlib import Path

import pandas as pd
import pytest

SCRIPT = Path(__file__).parents[1] / "scripts/02b_raj_pai_fuzzy_candidates.py"
SPEC = importlib.util.spec_from_file_location("pai_candidates", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def test_proposals_are_blocked_and_one_to_one() -> None:
    left = pd.DataFrame(
        {
            "election_gp_key": ["a", "b"],
            "canonical_group": ["d1__b1", "d2__b2"],
            "gp_name": ["mandawar", "kuchaman city"],
        }
    )
    right = pd.DataFrame(
        {
            "pai_row_key": ["x", "y", "z"],
            "canonical_group": ["d1__b1", "d2__b2", "d1__b1"],
            "gp_name": ["mandaawar", "kuchaman", "unrelated"],
        }
    )

    result = MODULE.propose_links(left, right)

    assert set(result.matches["election_gp_key"]) == {"a", "b"}
    assert not result.matches["left_index"].duplicated().any()
    assert not result.matches["right_index"].duplicated().any()
    assert (
        result.matches["canonical_group_left"]
        == result.matches["canonical_group_right"]
    ).all()


def test_proposals_reject_missing_keys() -> None:
    left = pd.DataFrame(
        {
            "election_gp_key": ["a"],
            "canonical_group": ["d1__b1"],
        }
    )
    right = pd.DataFrame(
        {
            "pai_row_key": ["x"],
            "canonical_group": ["d1__b1"],
            "gp_name": ["mandawar"],
        }
    )

    with pytest.raises(ValueError, match="Left input lacks"):
        MODULE.propose_links(left, right)


def test_proposals_reject_duplicate_business_keys() -> None:
    left = pd.DataFrame(
        {
            "election_gp_key": ["a", "a"],
            "canonical_group": ["d1__b1", "d1__b1"],
            "gp_name": ["mandawar", "mandawar"],
        }
    )
    right = pd.DataFrame(
        {
            "pai_row_key": ["x"],
            "canonical_group": ["d1__b1"],
            "gp_name": ["mandaawar"],
        }
    )

    with pytest.raises(ValueError, match="election_gp_key is not unique"):
        MODULE.propose_links(left, right)


def test_proposals_drop_low_similarity_pairs() -> None:
    left = pd.DataFrame(
        {
            "election_gp_key": ["a"],
            "canonical_group": ["d1__b1"],
            "gp_name": ["alpha"],
        }
    )
    right = pd.DataFrame(
        {
            "pai_row_key": ["x"],
            "canonical_group": ["d1__b1"],
            "gp_name": ["omega"],
        }
    )

    result = MODULE.propose_links(left, right)

    assert result.matches.empty
