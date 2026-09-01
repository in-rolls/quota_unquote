# Recode ledger

| variable | from | definition | universe | check | why |
|---|---|---|---|---|---|
| `an_women_reserved` | `raw_women_reserved_2020` | integer 1 for a women-reserved sarpanch seat and 0 for an open gender category | all election GPs | script asserts the observed set is exactly 0 and 1 | primary treatment |
| `assignment_stratum` | district, Panchayat Samiti, caste category | exact concatenation with `__` separators | all election GPs | no source field may be missing | proposed assignment block |
| `*_std` | each raw name | transliterate to ASCII, lowercase, replace punctuation with spaces, trim, collapse spaces | source field's universe | unit tests cover punctuation, accents, repeated whitespace, and missing values | deterministic exact matching before fuzzy linkage |
| `canonical_district_std` | normalized source group and approved override | use exact PAI district when the normalized district-block pair exists; otherwise use an approved group override | PAI 2.0 linkage candidates | targets must exist in PAI and left groups must be unique | boundary-stable blocking |
| `canonical_block_std` | normalized source group and approved override | use exact PAI block when the normalized district-block pair exists; otherwise use an approved group override | PAI 2.0 linkage candidates | same as district | boundary-stable blocking |
| `pai_available` | `pai_good_governance_score` | TRUE when a linked PAI score is present | every election GP and PAI version | equality asserted in `98_validate_design.R` | separate linkage attrition from a zero score |

No missing value is replaced with zero. The pipeline stops when source row counts, key cardinality, allowed treatment levels, or crosswalk targets differ from their documented contracts.
