# Nari Niti: Women's political reservations and local governance in India

Do seats reserved for women change how Gram Panchayats govern? This project studies the rotation of sarpanch reservations using direct measures of program leakage, social-audit findings, and the Panchayat Advancement Index (PAI). The first implemented design links Rajasthan's 2020 reservation cycle to PAI measures from fiscal years 2022-23 and 2023-24. The Rajasthan estimates are exploratory because the design was not frozen before estimation.

**Authors**: Data, Analysis, and Tools for India

## The question

The project asks whether reserving the sarpanch position for a woman changes corruption, accountability, and administrative governance in rural India. PAI measures governance procedures and reported performance, not corruption itself. Direct leakage and audit outcomes carry the corruption claim; PAI tests whether reservations change the procedures that may constrain it.

## Why it matters

Political reservations guarantee that women hold office. They do not guarantee that women exercise authority or that local government becomes more accountable. Separating direct corruption from administrative compliance lets the evidence distinguish those claims.

## Research design

The primary design compares Rajasthan Gram Panchayats assigned a women-reserved sarpanch seat in 2020 with otherwise eligible open seats in the same Panchayat Samiti and caste-reservation stratum. The primary outcome is the PAI 2.0 Good Governance score for fiscal year 2023-24. Identification requires the 2020 reservation allocation to be random within the reconstructed assignment strata and PAI availability not to select treated and open GPs differently.

## Current stage

The design is not frozen. At the author's direction, exploratory Rajasthan estimation began on September 1, 2026. [`pap.md`](pap.md) records the resulting unblinding and the decisions that remain open before any confirmatory extension.

## Rajasthan result

The PAI 2.0 estimate is -0.05 Good Governance points, with an HC2 95% confidence interval from -0.59 to 0.49 and a fixed-count randomization p-value of 0.847. This is -0.004 control-group standard deviations, with an interval from -0.049 to 0.040. In the linked, informative-strata sample, the estimate therefore rules out improvements larger than about 0.04 standard deviations.

PAI 1.0 yields 0.25 points, with a 95% interval from -0.26 to 0.76 and a randomization p-value of 0.338. Because the PAI versions use different indicators and scoring systems, this is a separate replication rather than a pooled second wave. Neither result measures corruption directly.

## Quick start

```bash
git clone https://github.com/in-rolls/nari_niti.git
cd nari_niti
R -e "renv::restore()"
uv sync --all-groups
PAI_DATA_DIR=/path/to/pai/consolidated Rscript scripts/99_run_all.R
make paper
```

`PAI_DATA_DIR` must contain `gp_metadata.csv` and `gp_scores_long.csv` rebuilt by [`in-rolls/pai`](https://github.com/in-rolls/pai) or extracted from its [Harvard Dataverse release](https://doi.org/10.7910/DVN/FRUKWS). The pipeline reads the Rajasthan election panel from a sibling `../quota_raj` clone unless `QUOTA_RAJ_PANEL` names an alternative file.

## Pipeline architecture

The difficult step is linking election-era Gram Panchayats to two versions of PAI without treating a failed link as a zero outcome. PAI 1.0 includes LGD GP codes, so it joins directly. PAI 2.0 omits those codes, so the pipeline first matches normalized official LGD district, block, and GP names, then uses normalized election names for the remaining rows. Every join preserves the election panel and writes treatment-specific coverage and unmatched examples.

```text
scripts/
├── 00_config.R                  # constants, labels, and figure style
├── 00_utils.R                   # source resolution, checks, and name normalization
├── 01a_pai_prepare.R            # PAI source profile and Rajasthan extract
├── 01b_raj_treatment_prepare.R  # Rajasthan reservation panel extract
├── 01c_pai2_group_audit.R       # manual district-block review evidence
├── 02a_raj_pai_join.R           # executable join contract and audit files
├── 02b_raj_pai_fuzzy_candidates.py # blinded residual GP proposals
├── 03a_raj_pai_effects.R        # exploratory Rajasthan effect estimates
├── 98_validate_design.R         # cross-artifact design gates
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

## Notes on analysis

### Stable outcome names

PAI 1.0 numbers its overall score and nine themes from 1 through 10. PAI 2.0 numbers them from 0 through 9. The pipeline selects `t8_panchayat_with_good_governance` by slug and refuses positional theme selection.

### PAI versions

PAI 1.0 and PAI 2.0 use different indicator sets and scoring systems. They are separate cross-sectional outcomes, not waves of a common panel measure. PAI 2.0 is the proposed primary outcome; PAI 1.0 is a separate replication.

### Interpretation boundary

The estimates are exploratory conditional comparisons until the official assignment mechanism is verified. The repository excludes fuzzy PAI 2.0 links until a stratified clerical review measures their precision and recall. PAI alone cannot support a corruption claim.

## Outputs

- Analysis-ready data: `data/nari_niti/nari_niti_gp_raj_2022_2024.parquet`
- Link audits: `data/crosswalks/audit/`
- Tables: `tabs/`
- Figures: `figs/`
- Manuscript: `ms/main.pdf`

## Requirements

- R 4.6 or newer
- Python 3.12 or newer and `uv`
- XeLaTeX and `latexmk`
