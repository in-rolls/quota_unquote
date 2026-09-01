# Data dictionary

One row in the analysis-ready file is one Rajasthan election GP from the 2015 to 2020 panel observed against one PAI version. The left table always remains the election panel, so the file has two rows per election GP even when no PAI record links.

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

## Open questions

- The 2020 reservation allocation frame and fixed treatment counts within each district, Panchayat Samiti, and caste category still require an official source.
- PAI 2.0 omits GP codes. The 77 nonexact district-block mappings passed blinded clerical review; `pai2_group_mapping_audit.csv` records the supporting counts and GP-name overlaps.
- GP fuzzy-link precision and recall remain unknown until a stratified clerical sample is labeled.
- PAI score missingness in the joined file currently means failed record linkage, not a portal score of zero.
