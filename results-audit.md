# Results audit

Verdict: the implemented estimates are internally correct for the stated linked-sample conditional associations. No number-changing defect survived verification. The UP result has narrower scope than a causal or corruption claim.

## Claim-to-estimand ledger

| claim | estimand and universe | source | inference | verdict |
|---|---|---|---|---|
| Women-reserved UP seats improve PAI 2.0 Good Governance | unweighted conditional difference among linked 2021 UP GPs in informative district by LGD block by caste strata | `03b_up_pai_effects.R`, `up_pai_effects.csv` | HC2 primary; CR2 by district-block companion; fixed-count RI sensitivity | Descriptive only; estimate is near zero |
| The UP result is not driven by accepted preclink election-to-LGD links | same model restricted to exact normalized election-to-LGD GP names | same | HC2 | Supported for the exact-link subset |
| The result replicates in PAI 1.0 | same linked-sample contrast using the distinct 2022/23 indicator system | same | HC2, CR2, RI sensitivity | Supported as a separate replication |
| Rajasthan shows the same pattern | analogous 2020 linked-sample contrast | `03a_raj_pai_effects.R`, `raj_pai_effects.csv` | HC2, CR2, RI sensitivity | Descriptive only and exploratory |
| Women pradhans reduce corruption | no direct leakage, bribery, or audit outcome in the PAI analysis | none | inapplicable | Unsupported by PAI |

## Check matrix

| check | evidence | result |
|---|---|---|
| Unit and denominator | one unweighted GP per PAI version; control SD computed within each analysis sample | passed |
| Missing versus zero | unmatched PAI scores remain missing; `pai_available` is explicit | passed |
| Row conservation | 49,773 UP election rows per wave; 99,546 stacked rows; unique year-by-election key | passed |
| Join cardinality | one-to-one accepted links; normalized PAI collisions excluded | passed |
| Differential availability | treatment-specific match-rate gaps below two percentage points in both waves | passed |
| Outcome range and tails | observed scores lie within 0 to 100; no heavy right tail | passed |
| Estimand | unweighted linked-sample conditional difference with informative-stratum support | passed |
| Regression implementation | HC2 estimate equals the within-stratum randomization statistic; CR2 cross-checked against the Rajasthan estimator | passed |
| Block influence | leave-one-assignment-block-out range stored with each result; no UP primary omission changes the estimate by more than 0.041 PAI points | passed |
| Randomization sensitivity | fixed treatment counts, 4,999 draws, fixed seeds, and `(k + 1) / (B + 1)` correction | passed conditionally on the assumed mechanism |
| Specification family | raw, stratum-adjusted, CR2, exact-link, PAI 1.0, and cross-state estimates reported | passed |
| Provenance | manuscript estimates are generated LaTeX macros or table fragments | passed after repair |
| Construct validity | PAI labeled as governance procedure and reported performance, not corruption | passed |

## Rejected candidates

- Differential missingness across PAI versions is real but does not manufacture the treatment comparison: availability differs sharply by version and by less than two percentage points by treatment within version.
- A failed PAI link is not coded as zero. The joined score has no observed zeros, and every unmatched score remains missing.
- The fast UP CR2 calculation is not a different model. Its within-stratum coefficient and Rajasthan cross-check reproduce the fixed-effect implementation.
- The near-zero estimate is not merely underpowered. The UP primary interval has a small upper bound in control-group standard deviations for the linked sample.

## Untestable or unresolved

- The official reservation roster algorithm has not been shown to randomize seats within the reconstructed strata.
- The portal extract does not cover the full official UP PAI 2.0 submission universe, so external validity to unlinked GPs is untestable.
- PAI is a formative administrative index. Item-level decomposition and measurement invariance cannot be audited from the consolidated theme score alone.
- Direct corruption outcomes have not yet been joined to the 2021 UP treatment.
