# Quota, Unquote

Do seats reserved for women change how local governments govern? In the linked Uttar
Pradesh and Rajasthan samples, women-reserved seats are associated with essentially no
difference in Panchayat Advancement Index (PAI) Good Governance scores. The UP estimate
is -0.04 points, with a 95% confidence interval from -0.40 to 0.31. The Rajasthan estimate
is -0.05 points, with an interval from -0.59 to 0.49. In Mumbai, where the city council's
women's seats are drawn by lot, residents rate councillors in reserved wards 0.07
control-group standard deviations higher on a 14-item index, with an interval from -0.10
to 0.24 and a randomization p-value of 0.44.

The UP and Rajasthan estimates are conditional associations: the official seat-allocation
mechanisms have not yet been shown to be random within the reconstructed comparison groups.
The Mumbai contrast is causal, because the draw is a lottery, but its outcome is what
residents perceive, not service delivery measured independently. None of these outcomes
measures leakage, bribery, or corruption.

## Research design

The treatment is whether the seat (sarpanch, pradhan, or Mumbai ward councillor) was
reserved for a woman, not the winner's sex. The analysis compares units within the smallest
reconstructed reservation-allocation strata, or, for Mumbai, within the lottery pool:

| State | Reservation cycle | Comparison strata | Status |
|---|---:|---|---|
| Uttar Pradesh | 2021 | District, LGD block, and caste-reservation class | Frozen before the outcome regression |
| Rajasthan | 2020 | Panchayat Samiti and caste-reservation class | Exploratory |
| Mumbai (BMC) | 2007, 2012, 2017 | The lottery pool: the council, and for 2012 the wards not reserved in 2007 | Specified after one exploratory pass elsewhere |

The primary estimator is an unweighted regression with assignment-stratum fixed effects
and HC2 standard errors. Block-clustered CR2 intervals and fixed-count randomization tests
are robustness checks. The [`design record`](docs/design.md) preserves the UP specification,
explains why the Rajasthan analysis is exploratory, and states the Mumbai specification
and what it was blind to. Commit `edd8b42` records the UP freeze.

## Data

The project joins four sources:

- [PAI](https://github.com/in-rolls/pai) Good Governance scores for fiscal years 2022-23
  and 2023-24.
- [Uttar Pradesh local elections](https://github.com/in-rolls/local_elections_up), including
  the 2021 reservation category and reviewed LGD links.
- [Rajasthan reservation data](https://github.com/in-rolls/quota_raj) for the 2020 sarpanch
  cycle.
- [local_reservations](https://github.com/in-rolls/local_reservations) for Mumbai: the seat
  reservation of the 2007, 2012 and 2017 councils and the Praja Foundation's ward-level
  citizen ratings of councillors, six survey waves from 2011 to 2018, mirrored there from
  the CC0 replication deposit of Karekurve-Ramachandra and Lee (2025),
  [doi:10.7910/DVN/IO9SLQ](https://doi.org/10.7910/DVN/IO9SLQ).

PAI 2.0 Good Governance for 2023-24 is the primary outcome. PAI 1.0 uses different
indicators and scoring rules, so its 2022-23 score is a separate replication rather than a
second observation of the same outcome.

PAI 1.0 includes LGD Gram Panchayat codes and joins directly. PAI 2.0 requires exact
normalized names within district and block. The Rajasthan linkage also uses manually
reviewed crosswalks for reorganized districts and blocks. Fuzzy matches enter the analysis
only after blinded clerical review. Failed links remain missing and are never coded as zero.

| State | Election GPs | PAI 2.0 linked | Link rate | Estimation sample |
|---|---:|---:|---:|---:|
| Uttar Pradesh | 49,773 | 23,921 | 48.1% | 23,763 |
| Rajasthan | 7,882 | 5,723 | 72.6% | 5,422 |
| Mumbai (BMC) | 681 ward seats | 681 rated | 100% | 681 |

UP link rates are 48.0% for women-reserved seats and 48.1% for other seats. Rajasthan rates
are 73.0% and 72.3%, respectively. Similar rates reduce concern about differential linkage,
but they do not recover unlinked Gram Panchayats. The current portal extract is incomplete:
the [official PAI 2.0 release](https://www.pib.gov.in/PressReleasePage.aspx?PRID=2256616&lang=1&reg=3)
reports validated submissions from all 57,678 UP Gram Panchayats.

## Key results

| State | Outcome | Estimate | 95% CI | Control SDs | Sample |
|---|---|---:|---:|---:|---:|
| Uttar Pradesh | PAI 2.0 | -0.04 | [-0.40, 0.31] | -0.002 | 23,763 |
| Rajasthan | PAI 2.0 | -0.05 | [-0.59, 0.49] | -0.004 | 5,422 |
| Mumbai (BMC) | Praja 14-item rating index | 0.05 | [-0.08, 0.18] | 0.067 | 681 |

The UP confidence interval excludes improvements larger than 0.018 control-group standard
deviations in the linked, informative-strata sample. Its PAI 1.0 estimate is -0.10 points
(95% CI: -0.40, 0.21). Restricting PAI 2.0 to exact election-to-LGD links, clustering by
block, and using fixed-count randomization inference all yield the same near-zero pattern.

The exploratory Rajasthan PAI 1.0 estimate is 0.25 points (95% CI: -0.26, 0.76). The
underlying values are generated by the analysis scripts and stored in
[`tabs/up_pai_effects.csv`](tabs/up_pai_effects.csv) and
[`tabs/raj_pai_effects.csv`](tabs/raj_pai_effects.csv).

Mumbai's index is the mean of fourteen within-wave standardised ratings (roads, water,
schools, sanitation, corruption, and so on), one survey wave per council. The interval in
control-group standard deviations runs from -0.10 to 0.24, so it neither shows an
improvement nor rules out the 0.16 to 0.18 that Desai, Karekurve-Ramachandra and Montero
(2024) report from the same surveys plus a non-public 2019 wave and Praja's own aggregate
grade. The 18-item index and dropping the one ward whose reservation the two sources
dispute give the same picture. Item by item, exploratory and unadjusted, residents in
reserved wards rate schools, law and order, power and water somewhat higher and the
councillor's personal accessibility no differently. Councillors in reserved seats attend
ward-committee meetings more (0.18 SD, 95% CI 0.01 to 0.34) and ask fewer questions in
council (-0.21 SD, -0.38 to -0.04). Values are in
[`tabs/bmc_praja_effects.csv`](tabs/bmc_praja_effects.csv),
[`tabs/bmc_praja_items.csv`](tabs/bmc_praja_items.csv) and
[`tabs/bmc_praja_activity.csv`](tabs/bmc_praja_activity.csv).

## Limits of the evidence

The UP and Rajasthan comparisons are not yet causal. Reservation laws establish rotation
and minimum shares, but they do not by themselves prove random allocation within the
reconstructed strata. Mumbai's draw is a lottery, so its contrast is causal for the seat.

PAI cannot answer whether women leaders reduce corruption. That claim requires direct
outcomes such as leakage, audit findings, procurement anomalies, or beneficiary fraud.

Incomplete portal coverage restricts the result to linked Gram Panchayats. Similar coverage
by treatment is useful evidence against one selection mechanism, not evidence for the
missing population.

Mumbai's outcome is a perception survey of about 100 residents per ward, and one of its
items, satisfaction with the councillor, is inverted in the 2018 wave and excluded. The
public data lack the 2019 wave. Three councils give 681 seats, so the interval is wide:
the design can tell a 0.3 SD effect from zero, not a 0.1 SD one.

## Reproduce the analysis

Requirements:

- R 4.6 or newer
- Python 3.12 or newer and `uv`
- XeLaTeX and `latexmk`

```bash
git clone https://github.com/in-rolls/quota_unquote.git
cd quota_unquote
R -e "renv::restore()"
uv sync --all-groups
PAI_DATA_DIR=/path/to/pai/consolidated Rscript scripts/99_run_all.R
make paper
```

`PAI_DATA_DIR` must contain the pinned `gp_metadata.csv` and `gp_scores_long.csv` files
from the [PAI Dataverse release](https://doi.org/10.7910/DVN/FRUKWS). The pipeline reads the
Rajasthan, UP and Mumbai files from sibling repositories by default. `QUOTA_RAJ_PANEL`,
`UP_ELECTION_FILE` and `LOCAL_RESERVATIONS_DIR` can point to other copies of the pinned
files. Expected paths, source
commits, and SHA-256 hashes are recorded in [`data/manifest.yaml`](data/manifest.yaml).

Run the project checks separately:

```bash
make sync
PAI_DATA_DIR=/path/to/pai/consolidated make data
make check
```

`make data` rebuilds the joined data, linkage audits, estimates, tables, and figures.
`make check` runs the R and Python tests, lint checks, design gates, and manuscript build.

## Repository guide

- `scripts/01*` prepare and profile source data.
- `scripts/02*` perform audited, row-preserving joins.
- `scripts/03*` estimate the state results and build the comparison figure; `03d` is Mumbai.
- `scripts/98*` enforce design and disclosure contracts.
- `tabs/` and `figs/` contain generated results.
- [`docs/design.md`](docs/design.md) records analysis status and specifications.
- [`docs/data.md`](docs/data.md) defines variables, recodes, and linkage contracts.

The manuscript source is [`ms/main.tex`](ms/main.tex); `make paper` builds `ms/main.pdf`.
