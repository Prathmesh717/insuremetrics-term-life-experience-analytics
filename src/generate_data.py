#!/usr/bin/env python3
"""Generate reproducible synthetic term-life policy and mortality data."""

from __future__ import annotations

import argparse
import csv
import math
import random
from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path


EXTRACT_DATE = date(2025, 12, 31)
BASIS_NAME = "LSL_2020_FICTIONAL"
LAPSE_BASIS_NAME = "LSL_2020_LAPSE_FICTIONAL"
PRODUCTS = (
    (1, "TERM10", "10-Year Level Term", 10),
    (2, "TERM20", "20-Year Level Term", 20),
    (3, "TERM30", "30-Year Level Term", 30),
)
STATES = ("TX", "CA", "FL", "NY", "IL", "GA", "NC", "OH")
FACE_AMOUNTS = (100_000, 250_000, 500_000, 750_000, 1_000_000)


@dataclass
class Policy:
    policy_id: int
    product_id: int
    issue_date: date
    issue_age: int
    sex: str
    smoker_status: str
    face_amount: int
    issue_state: str
    termination_date: date | None = None
    termination_reason: str | None = None


def add_years(day: date, years: int) -> date:
    try:
        return day.replace(year=day.year + years)
    except ValueError:
        return day.replace(month=2, day=28, year=day.year + years)


def qx(age: int, sex: str, smoker: str, duration: int) -> float:
    """Fictional select-and-ultimate annual mortality rate."""
    base = 0.00032 * math.exp(0.082 * (age - 30))
    sex_factor = 1.0 if sex == "M" else 0.72
    smoker_factor = 2.35 if smoker == "SM" else 1.0
    select_factor = {1: 0.70, 2: 0.78, 3: 0.86, 4: 0.92, 5: 0.97}.get(duration, 1.0)
    return min(0.35, max(0.00005, base * sex_factor * smoker_factor * select_factor))


def lapse_q(duration: int) -> float:
    return {1: 0.075, 2: 0.060, 3: 0.050, 4: 0.042, 5: 0.036}.get(duration, 0.030)


def random_date(rng: random.Random, start: date, end: date) -> date:
    return start + timedelta(days=rng.randrange((end - start).days + 1))


def generate_policy(rng: random.Random, policy_id: int) -> Policy:
    product_id = rng.choices((1, 2, 3), weights=(0.20, 0.55, 0.25), k=1)[0]
    issue_date = random_date(rng, date(2016, 1, 1), date(2025, 6, 30))
    issue_age = round(rng.triangular(20, 70, 42))
    sex = rng.choices(("M", "F"), weights=(0.54, 0.46), k=1)[0]
    smoker = rng.choices(("NS", "SM"), weights=(0.86, 0.14), k=1)[0]
    face = rng.choices(FACE_AMOUNTS, weights=(0.13, 0.31, 0.34, 0.12, 0.10), k=1)[0]
    return Policy(policy_id, product_id, issue_date, issue_age, sex, smoker, face, rng.choice(STATES))


def simulate_termination(rng: random.Random, policy: Policy) -> None:
    product_years = PRODUCTS[policy.product_id - 1][3]
    period_start = policy.issue_date
    duration = 1
    while period_start <= EXTRACT_DATE:
        period_end = min(add_years(policy.issue_date, duration) - timedelta(days=1), EXTRACT_DATE)
        attained_age = policy.issue_age + duration - 1
        expected = qx(attained_age, policy.sex, policy.smoker_status, duration)

        # Purposeful experience variation makes segmentation analytically useful.
        actual_factor = 1.18 if policy.smoker_status == "SM" else 0.94
        death_probability = 1 - (1 - expected * actual_factor) ** (((period_end - period_start).days + 1) / 365.25)
        lapse_probability = 1 - (1 - lapse_q(duration)) ** (((period_end - period_start).days + 1) / 365.25)
        draw = rng.random()
        if draw < death_probability:
            policy.termination_date = random_date(rng, period_start, period_end)
            policy.termination_reason = "DEATH"
            return
        if draw < death_probability + lapse_probability:
            policy.termination_date = random_date(rng, period_start, period_end)
            policy.termination_reason = "LAPSE"
            return
        if duration >= product_years:
            policy.termination_date = period_end
            policy.termination_reason = "MATURITY"
            return
        duration += 1
        period_start = period_end + timedelta(days=1)


def write_csv(path: Path, header: tuple[str, ...], rows) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(header)
        writer.writerows(rows)


def generate(output: Path, policy_count: int, seed: int) -> dict[str, int]:
    rng = random.Random(seed)

    write_csv(
        output / "products.csv",
        ("product_id", "product_code", "product_name", "level_term_years"),
        PRODUCTS,
    )

    assumptions = (
        (BASIS_NAME, sex, smoker, age, duration, f"{qx(age, sex, smoker, duration):.9f}")
        for sex in ("M", "F")
        for smoker in ("NS", "SM")
        for age in range(18, 121)
        for duration in range(1, 7)
    )
    write_csv(
        output / "mortality_assumptions.csv",
        ("basis_name", "sex", "smoker_status", "attained_age", "duration_year", "qx"),
        assumptions,
    )

    lapse_assumptions = (
        (LAPSE_BASIS_NAME, product_id, duration, f"{lapse_q(duration):.9f}")
        for product_id, *_ in PRODUCTS
        for duration in range(1, 31)
    )
    write_csv(
        output / "lapse_assumptions.csv",
        ("basis_name", "product_id", "duration_year", "lapse_qx"),
        lapse_assumptions,
    )

    policies = [generate_policy(rng, 1_000_001 + i) for i in range(policy_count)]
    for policy in policies:
        simulate_termination(rng, policy)

    write_csv(
        output / "policies.csv",
        ("policy_id", "product_id", "issue_date", "issue_age", "sex", "smoker_status", "face_amount", "issue_state", "termination_date", "termination_reason", "policy_status"),
        (
            (
                p.policy_id, p.product_id, p.issue_date.isoformat(), p.issue_age, p.sex,
                p.smoker_status, f"{p.face_amount:.2f}", p.issue_state,
                p.termination_date.isoformat() if p.termination_date else "",
                p.termination_reason or "", "TERMINATED" if p.termination_date else "INFORCE",
            )
            for p in policies
        ),
    )

    deaths = [p for p in policies if p.termination_reason == "DEATH"]
    write_csv(
        output / "death_claims.csv",
        ("claim_id", "policy_id", "date_of_death", "report_date", "paid_amount", "claim_status"),
        (
            (
                9_000_001 + i, p.policy_id, p.termination_date.isoformat(),
                (p.termination_date + timedelta(days=rng.randint(2, 45))).isoformat(),
                f"{p.face_amount:.2f}", "APPROVED",
            )
            for i, p in enumerate(deaths)
        ),
    )
    return {
        "policies": len(policies),
        "deaths": len(deaths),
        "lapses": sum(p.termination_reason == "LAPSE" for p in policies),
        "inforce": sum(p.termination_date is None for p in policies),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--policies", type=int, default=20000)
    parser.add_argument("--seed", type=int, default=20260828)
    parser.add_argument("--output", type=Path, default=Path(__file__).parents[1] / "data" / "generated")
    args = parser.parse_args()
    if args.policies < 100:
        parser.error("--policies must be at least 100")
    summary = generate(args.output, args.policies, args.seed)
    print("Generated synthetic experience data:", summary)


if __name__ == "__main__":
    main()
