# Data dictionary

One row in each analysis-ready file is one election GP observed against one PAI version. The left table always remains the election panel, so each file has two rows per election GP even when no PAI record links. Rajasthan contains the 2015 to 2020 panel. UP contains the canonical 2021 winners imported from `local_elections_up`.

| name | source file | type | unit | universe | values | missing codes | missing kind | transformation | provenance |
|---|---|---|---|---|---|---|---|---|---|
| `election_gp_key` | `quota_raj/...15_20_block.parquet` | character | election GP | all 2015 to 2020 linked election-panel rows | normalized district, block, GP composite | none observed | none | renamed from `match_key_2020` | `quota_raj` |
| `raw_district_2020` | same | character | election GP | all panel rows | Rajasthan 2020 district name | none observed | none | none | `district_std_2020` |
| `raw_block_2020` | same | character | election GP | all panel rows | Panchayat Samiti name | none observed | none | none | `samiti_std_2020` |
| `raw_gp_name_2020` | same | character | election GP | all panel rows | election GP name | none observed | none | none | `gp_std_2020` |
| `raw_women_reserved_2015` | same | integer | election GP | all panel rows | 0, 1 | none observed | none | none | `female_reserved_2015` |
| `raw_women_reserved_2020` | same | integer | election GP | all panel rows | 0, 1 | none observed | none | none | `female_reserved_2020` |
| `raw_caste_reservation_2020` | same | character | election GP | all panel rows | GEN, OBC, SC, ST | none observed | none | none | `caste_category_2020` |
| `raw_lgd_gp_code` | same | character | election GP | panel rows linked to an LGD GP | LGD identifier | blank or source `NA` | linkage missingness | coerced to character | `lgd_gp_code` |
| `raw_lgd_gp_name` | same | character | election GP | panel rows linked to an LGD GP | official GP name | source `NA` | linkage missingness | none | `lgd_gp_name` |
| `raw_lgd_block_code` | same | character | election GP | panel rows linked to an LGD block | LGD identifier | source `NA` | linkage missingness | coerced to character | `lgd_block_code` |
| `raw_lgd_block_name` | same | character | election GP | panel rows linked to an LGD block | official block name | source `NA` | linkage missingness | none | `lgd_block_name` |
| `raw_lgd_district` | same | character | election GP | panel rows linked to LGD | official district name | source `NA` | linkage missingness | none | `lgd_district` |
| `raw_lgd_match_type` | same | character | election GP | panel rows attempted in upstream LGD linkage | exact, fuzzy | source `NA` | linkage missingness | none | `match_type` |
| `raw_lgd_match_distance` | same | double | election GP | upstream fuzzy LGD matches | 0 to 1 | source `NA` | linkage missingness | none | `match_distance` |
| `an_women_reserved` | same | integer | election GP | all panel rows | 0, 1 | none allowed | none | integer copy of 2020 reservation | `01b_raj_treatment_prepare.R` |
| `assignment_stratum` | same | character | election GP | all panel rows | district, block, caste composite | none allowed | none | concatenated with explicit separators | `01b_raj_treatment_prepare.R` |
| `*_std` | both sources | character | source record | rows with the corresponding raw name | lowercase ASCII alphanumeric words | source `NA` remains `NA` | inherits source | Unicode transliteration, punctuation removal, whitespace collapse | `normalize_name()` |
| `pai_year` | PAI | character | election GP and PAI version | two rows per election GP | 2022-2023, 2023-2024 | none | none | source fiscal year | `01a_pai_prepare.R` |
| `pai_row_key` | PAI | character | PAI GP and version | PAI rows linked to the election panel | year, portal district, portal block, GP composite | missing on unmatched election GPs | linkage missingness | concatenated with explicit separators | `01a_pai_prepare.R` |
| `theme_slug` | PAI | character | election GP and version | all joined rows | `t8_panchayat_with_good_governance` | none | none | selected by stable slug | PAI portal |
| `pai_good_governance_score` | PAI | double | PAI GP | PAI GPs with a published Theme 8 score | 0 to 100 | missing on unmatched election GPs | linkage missingness | none | PAI portal |
| `pai_good_governance_grade` | PAI | character | PAI GP | PAI GPs with a published Theme 8 grade | source grade labels | missing on unmatched election GPs | linkage missingness | none | PAI portal |
| `pai_link_method` | derived | character | election GP and version | matched rows | direct code, exact name, reviewed fuzzy | missing on unmatched rows | linkage missingness | records the accepted pass | `02a_raj_pai_join.R` |
| `pai_available` | derived | logical | election GP and version | all joined rows | TRUE, FALSE | none | none | score is nonmissing | `02a_raj_pai_join.R` |

## UP fields

| name | source file | type | unit | universe | values | missing codes | missing kind | transformation | provenance |
|---|---|---|---|---|---|---|---|---|---|
| `election_gp_key` | `local_elections_up/...standardized.parquet` | character | 2021 election GP | all 2021 winner rows | stable source key | none | none | imported unchanged | `01d_up_treatment_prepare.R` |
| `raw_district_2021` | same | character | election GP | all 2021 rows | source district name | none | none | imported raw field | `local_elections_up` |
| `raw_block_2021` | same | character | election GP | all 2021 rows | source block name | none | none | imported raw field | `local_elections_up` |
| `raw_gp_name_2021` | same | character | election GP | 2021 rows with a published GP name | source GP name | blank | source missingness | imported raw field | `local_elections_up` |
| `raw_reservation_2021` | same | character | election GP | all 2021 rows | published reservation category | none | none | imported raw field | `local_elections_up` |
| `raw_lgd_block_code` | same | character | election GP | all 2021 rows | LGD block code | none | none | reviewed block crosswalk | `local_elections_up` |
| `raw_lgd_gp_code` | same | character | election GP | accepted election-to-LGD GP links | LGD GP code | missing when unlinked | linkage missingness | exact or reviewed preclink link | `local_elections_up` |
| `raw_lgd_gp_link_method` | same | character | election GP | accepted election-to-LGD GP links | exact normalized name, preclink | missing when unlinked | linkage missingness | imported unchanged | `local_elections_up` |
| `an_women_reserved` | same | integer | election GP | all 2021 rows | 0, 1 | none allowed | none | 1 only for an explicitly women-reserved seat | `01d_up_treatment_prepare.R` |
| `assignment_stratum` | same | character | election GP | all 2021 rows | district, LGD block, caste composite | none | none | concatenated with explicit separators | `01d_up_treatment_prepare.R` |
| `pai_link_method` | derived | character | election GP and version | matched UP rows | direct LGD code, exact official name, exact election name | missing when unmatched | linkage missingness | records the accepted join pass | `02c_up_pai_join.R` |
| `pai_available` | derived | logical | election GP and version | all joined UP rows | TRUE, FALSE | none | none | score is nonmissing | `02c_up_pai_join.R` |

## Open questions

- The 2020 reservation allocation frame and fixed treatment counts within each district, Panchayat Samiti, and caste category still require an official source.
- PAI 2.0 omits GP codes. The 77 nonexact district-block mappings passed blinded clerical review; `pai2_group_mapping_audit.csv` records the supporting counts and GP-name overlaps.
- Rajasthan GP fuzzy-link precision and recall remain unknown until a stratified clerical sample is labeled.
- The UP election-to-LGD accepted threshold has 75 accepted-band links checked by hand, all judged matches. Lower-scoring proposals remain outside the active crosswalk.
- PAI score missingness in the joined file currently means failed record linkage, not a portal score of zero.

## Join contract

### Rajasthan PAI 1.0

The left table is the 7,882-row Rajasthan election panel, keyed uniquely by
`election_gp_key`. PAI Theme 8 is unique by `gp_code`. The many-to-one direct LGD-code
join must preserve all 7,882 election rows; missing LGD codes remain unmatched.

### Rajasthan PAI 2.0 geography

The pipeline first joins normalized district-block groups exactly. Nonexact groups require
an approved row in `pai2_group_overrides.csv`. The active list contains 77 source groups
affected by spelling or Rajasthan's district reorganization. Review excluded treatment and
outcome fields. Each target must exist in PAI, each left group must be unique, and ambiguous
statewide block names require explicit evidence.

Within approved groups, exact normalized official GP names are tried first, followed by exact
normalized election names. Preclink Jaro-Winkler scores, a 0.85 threshold, a 0.05 margin, and
Hungarian assignment produce proposals only. A reviewer must approve a proposal before it
enters the analysis crosswalk. Accepted links are one to one and unmatched outcomes remain
missing.

### Uttar Pradesh election and PAI joins

The canonical `local_elections_up` release supplies exactly 49,773 2021 GP winner rows.
This repository imports its names, reservation recodes, LGD links, and collision flags rather
than maintaining parallel overrides.

PAI 1.0 joins accepted election-to-LGD GP codes directly. PAI 2.0 first uses exact normalized
official GP names within district and LGD block, then exact normalized election GP names among
unused rows. Accepted links must be one to one. Each wave preserves all 49,773 election rows,
and the stacked file must contain exactly 99,546 rows.

### Required diagnostics

- Row counts before and after every join.
- Key uniqueness on the required side.
- Match rates overall and by reservation status.
- Linked GPs and informative assignment strata by PAI version.
- No reuse of accepted PAI 2.0 rows.
- Unmatched examples from both sides.
- Precision and recall from a hand-labeled sample stratified by score and margin.

## Recode contract

| variable | definition | required check |
|---|---|---|
| `an_women_reserved` (Rajasthan) | 1 for a women-reserved 2020 sarpanch seat; 0 for an open-gender category | observed values are exactly 0 and 1 |
| `assignment_stratum` (Rajasthan) | district, Panchayat Samiti, and caste category joined with explicit separators | no component may be missing |
| `*_std` | ASCII transliteration, lowercase, punctuation replaced by spaces, and collapsed whitespace | unit tests cover punctuation, accents, whitespace, and missing values |
| `canonical_district_std`, `canonical_block_std` | exact PAI group or approved override | target exists in PAI and each left group is unique |
| `pai_available` | true exactly when a linked PAI Good Governance score is present | equality asserted by the design validators |
| `an_women_reserved` (UP) | 1 only when the 2021 reservation label explicitly identifies a women's category | values are exactly 0 and 1; winner sex is never used |
| `assignment_stratum` (UP) | canonical district, LGD block, and caste-reservation class | no component may be missing |
| `raw_lgd_gp_code` (UP) | exact-name or reviewed preclink link from the canonical election release | accepted links are one to one |

No missing value is replaced with zero. The pipeline stops when source row counts, key
cardinality, treatment levels, or crosswalk targets differ from these contracts.
