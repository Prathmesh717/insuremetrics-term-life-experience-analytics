# Validation and reconciliation controls

`sql/05_validation.sql` materializes every control, stores its latest result,
prints the control report, and raises a PostgreSQL exception when any failure
is non-zero. A failed control therefore stops the one-command pipeline.

| Control | Purpose |
|---|---|
| `orphan_claims` | Every claim resolves to a policy. |
| `invalid_claim_dates` | Death and report dates follow policy and claim chronology. |
| `death_policy_mismatch` | Claim death date agrees with death termination date and reason. |
| `invalid_exposure` | Exposure and segment endpoints satisfy bounds. |
| `segment_outside_study_window` | No exposure exists outside the observation period. |
| `segment_outside_policy_window` | No exposure precedes issue or follows termination. |
| `missing_assumption_match` | Every stored mortality row has a selected assumption. |
| `duplicate_policy_segment` | Policy-segment primary keys are unique. |
| `overlapping_or_gapped_segments` | Consecutive segments are contiguous. |
| `expected_death_calculation` | Stored expected deaths reproduce `E × qx`. |
| `expected_amount_calculation` | Stored expected amount reproduces `E × qx × face`. |
| `claims_vs_exposure_count` | Approved study-period claims equal actual deaths in exposure. |
| `claims_vs_exposure_amount` | Approved benefits equal actual claim amount in exposure. |
| `dimension_result_reconciliation` | Every mortality reporting view reconciles to portfolio totals. |
| `lapse_exposure_spine_mismatch` | Mortality and lapse use identical policy-time segments. |
| `lapse_expected_calculation` | Stored expected lapses reproduce `E × lapse q`. |
| `lapse_competing_termination` | Only voluntary lapse terminations count as actual lapses. |
| `lapses_vs_exposure_count` | Study-period lapse terminations equal exposure actuals. |
| `lapse_result_reconciliation` | Every lapse reporting view reconciles to portfolio totals. |

## Automated edge cases

`scripts/test_sql.sh` builds a four-policy fixture and verifies:

- leap-day issue advancing on a non-leap 28 February anniversary;
- a death exactly on an anniversary entering the new duration;
- one day of exposure on 31 December;
- exactly one life-year during leap-calendar-year 2024;
- no segment gaps or overlaps;
- a missing mortality assumption failing the exposure build.

The Python tests separately verify source/claim reconciliation and identical
file hashes for repeated generation with the same seed.
