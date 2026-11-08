# Assumption recommendation

## Decision summary

Maintain the current portfolio mortality and lapse bases for production use,
place mortality on enhanced monitoring, and initiate two targeted reviews:

1. TERM10 policies with face amounts of 500K–749K;
2. TERM30 duration-1 lapse experience.

No portfolio-wide basis change is supported by this synthetic study alone.

## Mortality assessment

Portfolio mortality produced 127 deaths against 113.91 expected, a count A/E
of 111.5%. The 95% interval is 92.9%–132.7%, which includes 100%. With 57.5%
limited-fluctuation credibility, the credibility-weighted A/E is 106.6%.
Accordingly, the rule-based action is `MONITOR`, not an immediate increase to
the portfolio mortality basis.

The most actionable diagnostic signal is TERM10 / 500K–749K:

- 4,307.8 life-years;
- 16 actual deaths versus 7.91 expected;
- count and amount A/E of 202.3%;
- 95% count A/E interval of 115.6%–328.5%;
- credibility-weighted A/E of 120.9%.

This segment receives `STRENGTHEN_ASSUMPTION`. Because it contains only 16
deaths and was selected after reviewing several cuts, the flag should trigger
underwriting, claim, and mix investigation before a factor is adopted.

Calendar year 2025 also warrants monitoring: count A/E was 124.1%, amount A/E
129.9%, and 11 of the portfolio's 24 large claims occurred in that year. Its
95% count interval still includes 100%.

## Lapse assessment

Portfolio lapse experience produced 3,006 lapses against 2,969.82 expected, an
A/E of 101.2%. The 95% interval is 97.6%–104.9%; full limited-fluctuation
credibility is achieved. The portfolio action is `MAINTAIN`.

TERM30 duration 1 produced 221 lapses against 187.31 expected, an A/E of
118.0%. Its 95% interval is 102.9%–134.6% and credibility-weighted A/E is
113.6%, resulting in `STRENGTHEN_LAPSE_ASSUMPTION`. The recommended next step
is to test whether acquisition channel, premium size, or issue cohort explains
the excess before changing the duration-1 factor.

## Governance before implementation

Any assumption change should require:

- replication on a refreshed extract;
- review of claim and termination coding;
- sensitivity testing on pricing, reserves, and profitability;
- actuarial sign-off on the credibility standard and selected segment;
- documented effective date, version, and rollback plan.
