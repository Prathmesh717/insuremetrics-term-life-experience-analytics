# Experience-study methodology

## Scope and study basis

The study measures mortality and voluntary lapse experience for synthetic
level-term policies observed from 1 January 2021 through 31 December 2025.
Mortality is compared with `LSL_2020_FICTIONAL`; lapse is compared with
`LSL_2020_LAPSE_FICTIONAL`. Neither basis represents a published table or a
real insurer assumption.

## Exposure construction

Each policy is intersected with the study window and split at two boundaries:

- 1 January, so every segment belongs to one calendar year;
- the policy anniversary, so every segment belongs to one duration.

Inclusive calendar-day exposure for segment `i` is:

```text
E_i = active calendar days in segment i / calendar days in that year
```

This convention gives a policy active for all of leap-calendar-year 2024
exactly 1.0 life-year. A policy issued on 29 February advances to its next
duration on 28 February in a non-leap anniversary year. Exposure stops on and
includes the first termination date. Death, lapse, and maturity therefore
compete for the same active policy time.

## Mortality measures

Attained age is issue age plus completed policy years. Select duration is
capped at duration 6 for assumption lookup.

```text
Expected deaths_i       = E_i × qx_i
Expected claim amount_i = E_i × qx_i × face amount_i
Count A/E               = actual approved deaths / expected deaths
Amount A/E              = approved death benefits / expected claim amount
```

Only approved claims are counted, using date of death. A death is assigned to
the single exposure segment containing that date.

## Lapse measures

The lapse study reuses the validated mortality exposure spine. A voluntary
lapse is assigned to the segment containing the policy termination date.

```text
Expected lapses_i = E_i × lapse q_i
Lapse A/E         = actual voluntary lapses / expected lapses
```

Death and maturity terminations never count as lapses, and no exposure is
generated after any termination.

## Segmentation

Mortality results are produced for portfolio, calendar year, issue cohort,
sex × smoking class, attained-age × duration, product × face-amount band, and
issue state. Lapse results are produced for portfolio, calendar year, duration,
product, product × duration, and face-amount band.

Cross-segment results are diagnostic views, not independent observations. A
policy contributes to several reporting views, but exactly once inside each
view.

## Statistical uncertainty

Death and lapse counts are treated as Poisson observations. The 95% count
interval uses the Byar approximation; the zero-count upper limit is
`-ln(0.025)`. Dividing the count limits by expected events produces the A/E
interval.

Limited-fluctuation credibility uses a 10% relative-error target at 95%
confidence:

```text
N_full = (1.96 / 0.10)^2 = 384.16 events
Z      = min(1, sqrt(actual events / 384.16))
Credibility-weighted A/E = 1 + Z × (raw A/E - 1)
```

The credibility standard is a transparent project convention, not a claim
that it is appropriate for every insurer or decision.

## Recommendation rules

Rules are applied consistently to mortality and lapse results:

1. exposure below 250 life-years or fewer than 5 actual events →
   `LOW_CREDIBILITY`;
2. 95% lower bound above 100% and credible A/E at least 110% → strengthen;
3. 95% upper bound below 100% and credible A/E at most 90% → weaken;
4. credible A/E at least 5 percentage points from 100% → `MONITOR`;
5. otherwise → `MAINTAIN`.

These flags prioritize actuarial review. They do not automatically update an
assumption table.
