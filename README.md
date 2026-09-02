# Quota, Unquote: Women's political reservations and local governance in India

Do seats reserved for women change how Gram Panchayats govern? This project links Rajasthan's 2020 sarpanch and Uttar Pradesh's 2021 pradhan reservation cycles to the Panchayat Advancement Index (PAI). The UP specification was frozen before estimation. The Rajasthan estimates are exploratory.

**Authors**: Data, Analysis, and Tools for India

## The question

The project asks whether reserving the sarpanch position for a woman changes corruption, accountability, and administrative governance in rural India. PAI measures governance procedures and reported performance, not corruption itself. Direct leakage and audit outcomes carry the corruption claim; PAI tests whether reservations change the procedures that may constrain it.

## Why it matters

Political reservations guarantee that women hold office. They do not guarantee that women exercise authority or that local government becomes more accountable. Separating direct corruption from administrative compliance lets the evidence distinguish those claims.

## Research design

The UP design compares Gram Panchayats with a women-reserved pradhan seat in 2021 with known non-women categories in the same district, LGD block, and caste-reservation class. Rajasthan uses the analogous 2020 comparison within Panchayat Samiti and caste-reservation strata. The primary outcome is the PAI 2.0 Good Governance score for fiscal year 2023-24. Identification requires reservation allocation to be random within the reconstructed strata.

## Current stage

[`pap-up.md`](pap-up.md) froze the UP estimand, sample, outcome, estimator, inference, and robustness checks before the UP outcome-on-treatment regression. Commit `edd8b42` records that freeze. [`pap.md`](pap.md) records why the Rajasthan estimates remain exploratory.

## UP result

The frozen PAI 2.0 estimate is near zero, and its confidence interval excludes even a small positive association in the linked informative-strata sample. PAI 1.0, exact election-to-LGD links, block-clustered CR2 inference, and fixed-count randomization sensitivity agree. The generated values are in [`tabs/up_pai_effects.csv`](tabs/up_pai_effects.csv); the paper presents them without hand-maintained copies.

## Rajasthan result

The exploratory Rajasthan estimates are also near zero. [`tabs/raj_pai_effects.csv`](tabs/raj_pai_effects.csv) contains the generated values. Because the two PAI versions use different indicators and scoring systems, PAI 1.0 is a separate replication rather than a pooled second wave.

## Quick start

```bash
git clone https://github.com/in-rolls/quota_unquote.git
cd quota_unquote
R -e "renv::restore()"
uv sync --all-groups
PAI_DATA_DIR=/path/to/pai/consolidated Rscript scripts/99_run_all.R
make paper
```

`PAI_DATA_DIR` must contain `gp_metadata.csv` and `gp_scores_long.csv` rebuilt by [`in-rolls/pai`](https://github.com/in-rolls/pai) or extracted from its [Harvard Dataverse release](https://doi.org/10.7910/DVN/FRUKWS). The pipeline reads Rajasthan elections from sibling `../quota_raj` and the canonical UP election release from sibling `../local_elections_up`. `QUOTA_RAJ_PANEL` and `UP_ELECTION_FILE` can name alternative pinned files.

## Pipeline architecture

The difficult step is linking election-era Gram Panchayats to two versions of PAI without treating a failed link as a zero outcome. PAI 1.0 includes LGD GP codes, so it joins directly. PAI 2.0 omits those codes, so the pipeline first matches normalized official LGD district, block, and GP names, then uses normalized election names for the remaining rows. Every join preserves the election panel and writes treatment-specific coverage and unmatched examples. UP election cleaning, name normalization, manual repairs, and LGD crosswalks live in `local_elections_up`; this repository imports its release instead of duplicating them.

```text
scripts/
├── 00_config.R                  # constants, labels, and figure style
├── 00_utils.R                   # source resolution, checks, and name normalization
├── 01a_pai_prepare.R            # PAI source profile and Rajasthan extract
├── 01b_raj_treatment_prepare.R  # Rajasthan reservation panel extract
├── 01c_pai2_group_audit.R       # manual district-block review evidence
├── 01d_up_treatment_prepare.R    # pinned canonical UP election import
├── 01e_up_pai_prepare.R          # UP PAI source profile
├── 02a_raj_pai_join.R           # executable join contract and audit files
├── 02b_raj_pai_fuzzy_candidates.py # blinded residual GP proposals
├── 02c_up_pai_join.R             # row-preserving exact UP PAI joins
├── 03a_raj_pai_effects.R        # exploratory Rajasthan effect estimates
├── 03b_up_pai_effects.R         # frozen UP estimates and robustness checks
├── 03c_pai_comparison.R         # common-scale cross-state figure
├── 98_validate_design.R         # Rajasthan design gates
├── 98b_validate_up_design.R     # frozen UP design gates
└── 99_run_all.R                 # explicit pipeline driver
```

## Data dependencies

The repository does not copy data owned by adjacent projects. [`data/manifest.yaml`](data/manifest.yaml) pins the expected files and hashes.

### PAI

- Source: [`in-rolls/pai`](https://github.com/in-rolls/pai)
- Release: [doi:10.7910/DVN/FRUKWS](https://doi.org/10.7910/DVN/FRUKWS)
- Required files: `gp_metadata.csv`, `gp_scores_long.csv`

### Rajasthan reservations

- Source: [`in-rolls/quota_raj`](https://github.com/in-rolls/quota_raj)
- Required file: `data/raj/shrug_gp_raj_15_20_block.parquet`

### UP elections

- Source: [`in-rolls/local_elections_up`](https://github.com/in-rolls/local_elections_up)
- Required file: `data/fin/up_gp_elections_standardized.parquet`
- Contents: canonical 2005, 2010, 2015, and 2021 GP election fields, reviewed name repairs, LGD block mapping, and accepted GP links

## Notes on analysis

### Stable outcome names

PAI 1.0 numbers its overall score and nine themes from 1 through 10. PAI 2.0 numbers them from 0 through 9. The pipeline selects `t8_panchayat_with_good_governance` by slug and refuses positional theme selection.

### PAI versions

PAI 1.0 and PAI 2.0 use different indicator sets and scoring systems. They are separate cross-sectional outcomes, not waves of a common panel measure. PAI 2.0 is the proposed primary outcome; PAI 1.0 is a separate replication.

### Interpretation boundary

The UP specification is frozen, but all estimates remain conditional comparisons until the official assignment mechanisms are verified. PAI alone cannot support a corruption claim.

### UP portal coverage

The pinned portal extract is incomplete. The [official PAI 2.0 release](https://www.pib.gov.in/PressReleasePage.aspx?PRID=2256616&lang=1&reg=3) says that all 57,678 UP Gram Panchayats submitted and validated data, but repeated portal downloads return "Details are not available" for many blocks. Missing PAI rows in this repository therefore describe portal extraction and linkage coverage, not governance outcomes. Treatment-specific match rates are nearly identical, which is reassuring for differential selection but does not recover the unobserved population.

## Outputs

- Analysis-ready data: `data/quota_unquote/quota_unquote_gp_raj_2022_2024.parquet`
- UP analysis-ready data: `data/quota_unquote/quota_unquote_gp_up_2022_2024.parquet`
- Link audits: `data/crosswalks/audit/`
- Tables: `tabs/`
- Figures: `figs/`
- Manuscript: `ms/main.pdf`

## Requirements

- R 4.6 or newer
- Python 3.12 or newer and `uv`
- XeLaTeX and `latexmk`
