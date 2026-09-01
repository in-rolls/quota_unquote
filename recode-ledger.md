# Recode ledger

| variable | from | definition | universe | check | why |
|---|---|---|---|---|---|
| `an_women_reserved` | `raw_women_reserved_2020` | integer 1 for a women-reserved sarpanch seat and 0 for an open gender category | all election GPs | script asserts the observed set is exactly 0 and 1 | primary treatment |
| `assignment_stratum` | district, Panchayat Samiti, caste category | exact concatenation with `__` separators | all election GPs | no source field may be missing | proposed assignment block |
| `*_std` | each raw name | transliterate to ASCII, lowercase, replace punctuation with spaces, trim, collapse spaces | source field's universe | unit tests cover punctuation, accents, repeated whitespace, and missing values | deterministic exact matching before fuzzy linkage |
| `canonical_district_std` | normalized source group and approved override | use exact PAI district when the normalized district-block pair exists; otherwise use an approved group override | PAI 2.0 linkage candidates | targets must exist in PAI and left groups must be unique | boundary-stable blocking |
| `canonical_block_std` | normalized source group and approved override | use exact PAI block when the normalized district-block pair exists; otherwise use an approved group override | PAI 2.0 linkage candidates | same as district | boundary-stable blocking |
| `pai_available` | `pai_good_governance_score` | TRUE when a linked PAI score is present | every election GP and PAI version | equality asserted in `98_validate_design.R` | separate linkage attrition from a zero score |
| `an_women_reserved` (UP) | canonical `women_reserved` | 1 only when the 2021 source reservation explicitly names a female category; 0 for a known non-women category | all 2021 GP winner rows | source release and analysis gate require only 0 and 1 | UP treatment; winner sex is never used to impute reservation |
| `assignment_stratum` (UP) | canonical district, LGD block, caste reservation class | exact concatenation with `__` separators | all 2021 GP winner rows | no component may be missing | frozen UP adjustment stratum |
| `raw_lgd_gp_code` (UP) | accepted canonical LGD crosswalk | retain exact-name and reviewed preclink links; leave lower-scoring proposals missing | all 2021 GP winner rows | accepted links are one to one and threshold sample is manually labeled | official-name path to PAI 1.0 and PAI 2.0 |
| `pai_available` (UP) | `pai_good_governance_score` | TRUE when a linked PAI score is present | every UP election GP and PAI version | equality asserted in `98b_validate_up_design.R` | preserve portal and linkage missingness |

No missing value is replaced with zero. The pipeline stops when source row counts, key cardinality, allowed treatment levels, or crosswalk targets differ from their documented contracts.
