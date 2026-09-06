from __future__ import annotations

import importlib.util
from pathlib import Path

import pandas as pd
import pytest

SCRIPT = Path(__file__).parents[1] / "scripts/00c_pai_theme8_indicators.py"
SPEC = importlib.util.spec_from_file_location("pai_indicators", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def test_committed_indicator_table_meets_its_contract() -> None:
    frame = MODULE.read()
    assert len(frame) == 62 + 26
    kinds = frame.groupby(["pai_version", "kind"]).size().to_dict()
    assert kinds == {
        ("PAI 1.0", "binary"): 35,
        ("PAI 1.0", "ratio"): 27,
        ("PAI 2.0", "binary"): 23,
        ("PAI 2.0", "ratio"): 3,
    }


def test_validate_rejects_duplicate_keys_and_bad_kinds() -> None:
    frame = MODULE.read()
    duplicated = pd.concat([frame, frame.iloc[[0]]], ignore_index=True)
    with pytest.raises(ValueError, match="not unique"):
        MODULE.validate(duplicated)
    wrong_kind = frame.copy()
    wrong_kind.loc[0, "kind"] = "percentage"
    with pytest.raises(ValueError, match="kind outside"):
        MODULE.validate(wrong_kind)
    lost_row = frame.iloc[1:].reset_index(drop=True)
    with pytest.raises(ValueError, match="Indicator counts"):
        MODULE.validate(lost_row)


def test_pai_2_page_is_requested_before_pai_1_to_seed_the_session() -> None:
    calls: list[int] = []

    def fake_fetch(session_id: int, opener: object) -> str:
        calls.append(session_id)
        return ""

    pages = MODULE.fetch_pages(opener=object(), fetch_one=fake_fetch)
    assert calls == [2, 1]
    assert set(pages) == {1, 2}


def test_parse_and_classify_from_portal_markup() -> None:
    page = (
        "<table><tr><td>1</td><td>Mandatory</td>"
        "<td>Percentage of Grievances redressed [469]</td>"
        "<td>Grievances redressed [900]</td><td>Grievances received [901]</td></tr>"
        "<tr><td>2</td><td>Mandatory</td>"
        "<td>Whether Gram Sabha has been conducted [717]</td>"
        "<td>Whether Gram Sabha has been conducted [717]</td><td></td></tr></table>"
    )
    rows = MODULE.parse(page)
    assert [row[1] for row in rows] == [
        "Percentage of Grievances redressed [469]",
        "Whether Gram Sabha has been conducted [717]",
    ]
    assert MODULE.classify("Percentage of Grievances redressed", "a", "b") == "ratio"
    assert MODULE.classify("Whether Gram Sabha conducted", "x", "x") == "binary"
    assert MODULE.classify("Number of works monitored", "works", "") == "number"
    assert (
        MODULE.classify("Whether ward sabhas held", "sabhas held", "wards") == "ratio"
    )
