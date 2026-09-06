# Changelog

## v0.1.0 (2026-09-05)

First tagged release.

- PAI inputs come from [PAI release v0.2.0](https://github.com/in-rolls/pai/releases/tag/v0.2.0)
  (`pai_gp.parquet`, pinned by SHA-256 in `data/manifest.yaml`), which scores every Uttar
  Pradesh and Rajasthan Gram Panchayat in both vintages and carries an LGD code on every row.
- Both PAI waves join on the reviewed election-to-LGD GP code. A code link is kept only when
  the PAI name equals the LGD name after normalization; the three UP conflicts are dropped and
  listed in `up_pai_code_name_conflicts.csv`. Fuzzy name proposals never enter the primary
  sample. The Rajasthan results also report the estimate restricted to direct-code links.
- UP PAI 2.0 linkage rises from 23,921 (48.1%) to 38,388 (77.1%) of the 49,773 winners. The
  frozen specification, unchanged, gives 0.07 points (95% CI -0.22, 0.36); the frozen-sample
  result (-0.04) is kept in `docs/design.md`. Rajasthan and Mumbai results are unchanged.
- README, data dictionary and paper now describe the indicators behind the Good Governance
  theme; `docs/pai_theme8_indicators.csv` holds both lists as fetched from the PAI portal.
- No continuous integration runs in this repository; the checks for this release ran locally
  (`make check`) and were repeated by an independent reviewer.
