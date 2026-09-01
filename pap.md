# Pre-analysis plan: Nari Niti

Status: draft, not frozen, not tagged, and unblinded.

Data state at draft: source rows, marginal outcome distributions, record-linkage coverage, and treatment-specific linkage availability were examined before estimation. At the author's direction, exploratory Rajasthan outcome analysis began on September 1, 2026, before this plan was frozen. This plan cannot serve as a prospective registration or support a confirmatory label for the Rajasthan PAI estimates.

## 1. Question and estimand

Proposed estimand: the unweighted intention-to-treat effect on the fiscal year 2023/24 PAI 2.0 Good Governance score of reserving the sarpanch seat for a woman in 2020 rather than leaving its gender category open, among Rajasthan Gram Panchayats in the verified 2020 assignment frame with an approved PAI link, averaged over GPs within Panchayat Samiti and caste-reservation assignment strata.

Open decision: whether the target population should remain the approved-link sample or the full assignment frame with partial-identification bounds for linkage failure.

## 2. Identification

Assumption: conditional on the official 2020 assignment strata and eligibility rules, women-reserved seats were allocated independently of each GP's potential PAI outcomes.

The assumption fails if the rotation order used population, prior performance, boundary changes, or discretionary administrative choices not represented in the reconstructed strata. Official rules and rosters can test the reconstruction, and pretreatment balance can reveal some failures, but random assignment itself is not established by a balance test.

If the assignment rule cannot be reconstructed, the PAI analysis becomes a conditional association rather than a causal effect.

## 3. Hypotheses

| hypothesis | outcome | predicted sign | proposed magnitude | status |
|---|---|---|---|---|
| H1 | PAI 2.0 Good Governance score | positive | 0.05 to 0.15 control-group standard deviations | needs author approval and a literature-based prior |
| H2 | PAI 1.0 Good Governance score | positive | same standardized range, interpreted as a separate construct | replication |
| H3 | approved PAI-link availability | zero | absolute difference below 2 percentage points | linkage falsification |

## 4. Primary specification

Proposed sample: GPs in the verified Rajasthan 2020 assignment frame with an approved PAI 2.0 link. Fuzzy links require blinded clerical approval.

Proposed estimator: an unweighted difference in means adjusted for the exact assignment strata. Randomization inference will reproduce the official allocation mechanism within strata. A model-based companion estimate will use explicit CR2 standard errors at the Panchayat Samiti level only if the institutional assignment account justifies that level.

No population or card weights enter the primary model. A population-weighted estimand is secondary and will be labeled as a different quantity.

## 5. What else should be true

- Pretreatment Census covariates should not jointly predict 2020 reservation within the assignment frame.
- Reservation should not predict whether a GP receives an approved PAI link.
- A future reservation, if a later roster becomes available, should not predict an earlier PAI outcome.
- Effects should be larger on transparency and participation indicators than on slow-moving line-department outcomes if accountability is the mechanism.
- Prior reservation is a prespecified precision variable and heterogeneity dimension, not a post-treatment control.

## 6. Multiplicity

The sole primary PAI outcome is the PAI 2.0 Good Governance score. PAI 1.0 Good Governance is a separate replication. Overall PAI, Women-Friendly Panchayat, and any indicator subfamilies are secondary. Secondary indicators will be grouped into prespecified Anderson indices and adjusted within family. No subgroup is confirmatory until listed here before the plan is frozen.

## 7. Design analysis

The design analysis will use the approved assignment frame, fixed treatment counts, and randomization mechanism. It will report 80 percent power, Type S error, and Type M exaggeration at the approved prior effect sizes. No power result is frozen yet.

## 8. Missing data and linkage

A missing PAI value in the joined file is a failed link, not a zero. Link availability is reported by treatment before any outcome model. The primary complete-link estimate will be accompanied by sensitivity to exact-only links, approved fuzzy links, and bounds for differential linkage when informative.

## 9. What would change the claim

The PAI evidence cannot support a corruption claim if direct leakage and audit outcomes do not move in the same direction. A PAI effect on procedural scores alone will be described as a change in measured governance or administrative compliance.

## 10. Decisions required before freeze

1. Confirm the unweighted GP estimand and its target population.
2. Confirm the official assignment strata and randomization mechanism.
3. Approve PAI 2.0 Good Governance as the sole primary PAI outcome.
4. Approve the expected effect range and the finite subgroup list.
5. Decide whether to split or hold out geography despite the loss of power.

## 11. Deviations

- 2026-09-01: The author requested the Rajasthan analysis before the plan was frozen. The announced unweighted, assignment-stratum-adjusted PAI 2.0 specification was run with HC2 inference and 4,999 fixed-count within-stratum randomizations. PAI 1.0 was run separately as a replication. All resulting estimates are labeled exploratory.
