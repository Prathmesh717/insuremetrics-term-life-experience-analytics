# Data dictionary

## `product`

| Field | Meaning |
|---|---|
| `product_id` | Stable product key |
| `product_code` | Business-facing product code |
| `product_name` | Product description |
| `level_term_years` | Guaranteed level-term period |

## `policy`

One row per issued coverage.

| Field | Meaning |
|---|---|
| `policy_id` | Synthetic policy identifier |
| `product_id` | Product foreign key |
| `issue_date` | Coverage effective date |
| `issue_age` | Age at issue, age-nearest-birthday simplification |
| `sex` | Rating sex (`M` or `F`) |
| `smoker_status` | Underwriting tobacco class (`NS` or `SM`) |
| `face_amount` | Death benefit at issue |
| `issue_state` | Synthetic issue jurisdiction |
| `termination_date` | Date coverage left in-force, when applicable |
| `termination_reason` | `DEATH`, `LAPSE`, `MATURITY`, or null |
| `policy_status` | Status as of the data extract date |

## `mortality_assumption`

Fictional annual mortality assumptions. `duration_year` 1–5 represents select rates; 6 represents durations 6 and later.

| Field | Meaning |
|---|---|
| `basis_name` | Assumption version name |
| `sex` | Rating sex |
| `smoker_status` | Tobacco class |
| `attained_age` | Age used to select the annual rate |
| `duration_year` | Capped select duration |
| `qx` | Annual probability of death |

## `lapse_assumption`

Fictional annual voluntary lapse assumptions by product and policy duration.

| Field | Meaning |
|---|---|
| `basis_name` | Versioned lapse basis identifier |
| `product_id` | Product foreign key |
| `duration_year` | Policy duration used for lookup |
| `lapse_qx` | Annual probability of voluntary lapse |

## `death_claim`

One row per reported death claim. Only `APPROVED` claims enter actual mortality.

## `experience_study`

Study governance record defining the observation window and mortality and
lapse assumption bases.

## `exposure_record`

Derived policy-calendar-year segments. This is the central actuarial fact table used by the mortality queries.

## `mortality_experience_detail`

Enriched analytical view joining mortality exposure to product and policy
dimensions. It defines issue cohort, attained-age band, duration band,
face-amount band, and large-claim indicator once for consistent reporting.

## `mortality_result`

Decision-oriented mortality result mart.

| Field | Meaning |
|---|---|
| `analysis_name` | Reporting view such as `calendar_year` or `age_duration` |
| `dimension_1_*`, `dimension_2_*` | Flexible segment names and values |
| `count_ae_ratio` | Actual deaths divided by expected deaths |
| `count_ae_lower_95`, `count_ae_upper_95` | Poisson-based 95% A/E interval |
| `credibility` | Limited-fluctuation credibility factor |
| `credible_count_ae` | A/E blended toward 1.0 using credibility |
| `amount_ae_ratio` | Actual divided by expected claim amount |
| `excess_deaths` | Actual minus expected deaths |
| `claim_amount_variance` | Actual minus expected claim amount |
| `large_claim_count` | Claims of at least 750K |
| `recommended_action` | Rule-based governance triage flag |

## `lapse_exposure_record`

Lapse fact table reusing the mortality policy-time spine. It stores selected
lapse rate, expected lapses, and the actual voluntary-lapse indicator.

## `lapse_result`

Segmented lapse A/E results with Poisson interval, credibility, excess lapses,
and governance action.

## `study_validation_result`

Persistent latest-run result for each fail-fast validation control. These rows
feed the dashboard Controls tab and exported validation CSV.
