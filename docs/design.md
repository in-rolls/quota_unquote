# Analysis design and status

## Uttar Pradesh: frozen analysis plan

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

## Post-freeze results

The design was frozen in commit `edd8b42cd4997fc0a01e516031cd886f3e66f099` before the first UP outcome-on-treatment regression. `tabs/up_pai_effects.csv` is the numerical source of truth.

The primary PAI 2.0 conditional difference is -0.0419 points with an HC2 95% confidence interval from -0.3963 to 0.3125. This is -0.0024 control-group standard deviations with an interval from -0.0224 to 0.0176. The fixed-count randomization sensitivity yields 0.8182. PAI 1.0, CR2 block clustering, and the exact election-to-LGD subset agree with the near-zero primary result.

The analysis supports a precise null conditional association in the linked informative-strata sample. It does not establish a causal effect or an effect on corruption.

## Deviations and implementation notes

- No frozen estimand, outcome, sample rule, weighting rule, fixed effect, interval method, exact-link restriction, or randomization count changed after unblinding.
- The CR2 companion uses the Frisch-Waugh-Lovell within-stratum transformation followed by `clubSandwich::vcovCR(type = "CR2")`. This is algebraically equivalent to the frozen fixed-effect regression and reproduces the Rajasthan `estimatr::lm_robust` coefficient and CR2 standard error.
- The fixed-count randomization sampler was implemented in Rcpp because materializing the full assignment matrix would require roughly one gigabyte. The statistic, number of draws, seed, strata, treatment counts, and finite-sample p-value correction remain as frozen.

## Rajasthan: exploratory analysis

The Rajasthan analysis was not preregistered or frozen before estimation. Source rows,
outcome distributions, linkage coverage, and treatment-specific availability had already
been examined when exploratory outcome analysis began on September 1, 2026. Its estimates
must remain labeled exploratory.

The analysis uses an unweighted comparison of women-reserved and open-gender sarpanch seats
within reconstructed Panchayat Samiti and caste-reservation strata. Its causal interpretation
would require the official 2020 allocation to be random within those strata. Rotation order,
population rules, boundary changes, or administrative discretion could violate that condition.

PAI 2.0 Good Governance is the principal Rajasthan outcome, with PAI 1.0 treated as a
separate replication because the indicator systems differ. Failed links remain missing and
are never recoded as zero. Because exploratory Rajasthan outcome analysis began before the
design was frozen, neither the estimates nor later robustness checks are confirmatory.
