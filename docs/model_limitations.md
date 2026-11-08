# Model limitations

The project is an analytical demonstration, not a production actuarial
opinion. Its conclusions should be interpreted with the following limits.

## Data

- All policies, assumptions, claims, and results are synthetic.
- Experience variation is partly embedded in the generator, so discovery on
  this dataset is not independent evidence of a real risk relationship.
- The extract includes approved claims without incurred-but-not-reported or
  pending-claim development.
- Policy fields omit underwriting class, distribution channel, premium,
  reinsurance, conversion, reinstatement, and policy changes.

## Actuarial model

- Expected events use the fractional approximation `exposure × annual rate`
  rather than an exact survival or multiple-decrement calculation.
- Issue age is a simplified age-nearest-birthday field and does not recalculate
  from date of birth.
- Mortality duration 6 is used for every later duration.
- Lapse assumptions vary only by product and duration.
- Death and lapse analyses share exposure but do not model dependent causes of
  decrement jointly.

## Statistical interpretation

- The Poisson model assumes independent events and proportional variance.
- Byar intervals are approximations.
- Limited-fluctuation credibility is only one credibility method; the 10%
  error target and 95% confidence level are project choices.
- Numerous segment views create multiple-testing and selection risk. A flagged
  segment may be extreme by chance.
- Credibility weighting toward 100% is a governance aid, not a fitted best
  estimate or Bayesian posterior.

## Decision scope

- Recommendation labels are deterministic triage rules, not autonomous
  assumption updates.
- No pricing, reserve, capital, or profit sensitivity is included.
- State results should not be interpreted as causal geographic effects.
- The 750K large-claim threshold is a reporting convention.

Production use would require real-data governance, independent methodology
review, claim-lag analysis, sensitivity testing, and formal actuarial approval.
