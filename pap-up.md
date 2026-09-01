# Frozen UP analysis plan

Status: frozen on September 1, 2026, before any UP outcome-on-treatment
regression was run. Source outcomes, marginal distributions, overall linkage,
and treatment-specific linkage rates had already been examined. This is an
analysis freeze, not a prospective registration.

## Question and estimand

The directional hypothesis is that reserving the 2021 pradhan seat for a woman
increases the subsequent PAI Good Governance score. The estimand is the
unweighted conditional difference associated with a women-reserved rather than
a known non-women-reserved seat among linked UP GPs in informative
district--block--caste reservation strata.

The primary outcome is the 2023/24 PAI 2.0 Good Governance score. The 2022/23
PAI 1.0 Good Governance score is a separate replication because the indicator
systems differ.

## Identification and claim

The UP Panchayat Raj Act establishes rotation and a minimum women-reservation
share but does not, by itself, establish random allocation within the
reconstructed strata. Unless the 2021 roster algorithm is independently shown
to be as-if random conditional on district, block, and caste reservation class,
the coefficient is a conditional association. Randomization inference is a
sensitivity calculation under the stated fixed-count assignment model, not
evidence that the model governed the actual roster.

PAI measures reported governance procedure and performance. It is not a direct
measure of leakage, bribery, or corruption, so this analysis cannot by itself
support the claim that women pradhans reduce corruption.

## Primary specification

- Unit: one 2021 GP winner/seat.
- Treatment: `women_reserved`, coded 1 only when the source reservation label
  explicitly contains `Female`, 0 for known non-women categories, and never
  imputed from the winner's sex.
- Sample: linked PAI 2.0 rows in strata containing both treatment levels.
- Strata: canonical 2021 district, current LGD block, and caste reservation
  class (`general`, `obc`, `sc`, or `st`).
- Estimator: unweighted OLS with assignment-stratum fixed effects.
- Primary uncertainty: HC2 standard errors and 95% confidence interval.
- Companion uncertainty: CR2 standard errors clustered by canonical
  district--block.
- Scale: PAI points and control-group standard deviations.
- Randomization sensitivity: 4,999 fixed-count permutations within informative
  strata, seed 20260901.

## Prespecified diagnostics and robustness

1. Report linkage rates by treatment for both PAI waves.
2. Report the raw linked-sample difference without stratum adjustment.
3. Repeat the specification for PAI 1.0.
4. Repeat using only exact election-to-LGD GP links.
5. Report informative strata, blocks, control mean, and control SD.
6. Preserve all unmatched rows and never code failed linkage as a zero score.

No subgroup, alternative PAI theme, covariate search, population weighting, or
functional-form search is primary. Any such result must be labeled exploratory.

## Frozen inputs

- `local_elections_up` commit `3e19684df019be328664f2f98362d789874855d9`
- Standardized election SHA-256
  `986893d620e3d1d0d46e3d306909cc7acf3ccbae383346e4f47b39de9f62fe76`
- PAI consolidated files are pinned in `data/manifest.yaml`.
- UP joined-file row contract: 49,773 election rows per PAI wave.

