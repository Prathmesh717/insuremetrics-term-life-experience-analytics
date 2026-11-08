import csv
import hashlib
import tempfile
import unittest
from datetime import date
from pathlib import Path

import sys

sys.path.insert(0, str(Path(__file__).parents[1] / "src"))
from generate_data import EXTRACT_DATE, generate, qx  # noqa: E402


class GeneratorTests(unittest.TestCase):
    def test_mortality_increases_with_age_and_smoking(self):
        self.assertGreater(qx(60, "M", "NS", 6), qx(40, "M", "NS", 6))
        self.assertGreater(qx(50, "F", "SM", 6), qx(50, "F", "NS", 6))

    def test_generated_policy_and_claim_reconciliation(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir)
            summary = generate(output, 500, 12345)

            with (output / "policies.csv").open(newline="", encoding="utf-8") as handle:
                policies = list(csv.DictReader(handle))
            with (output / "death_claims.csv").open(newline="", encoding="utf-8") as handle:
                claims = list(csv.DictReader(handle))

            death_policies = {row["policy_id"]: row for row in policies if row["termination_reason"] == "DEATH"}
            self.assertEqual(summary["policies"], 500)
            self.assertEqual(len(claims), summary["deaths"])
            self.assertEqual(set(death_policies), {row["policy_id"] for row in claims})
            for claim in claims:
                policy = death_policies[claim["policy_id"]]
                self.assertEqual(claim["date_of_death"], policy["termination_date"])
                self.assertLessEqual(date.fromisoformat(claim["date_of_death"]), EXTRACT_DATE)

    def test_generation_is_reproducible_for_the_same_seed(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            first = root / "first"
            second = root / "second"
            third = root / "third"

            first_summary = generate(first, 500, 24680)
            second_summary = generate(second, 500, 24680)
            generate(third, 500, 13579)

            self.assertEqual(first_summary, second_summary)
            for filename in (
                "products.csv",
                "mortality_assumptions.csv",
                "lapse_assumptions.csv",
                "policies.csv",
                "death_claims.csv",
            ):
                first_digest = hashlib.sha256((first / filename).read_bytes()).digest()
                second_digest = hashlib.sha256((second / filename).read_bytes()).digest()
                self.assertEqual(first_digest, second_digest, filename)

            self.assertNotEqual(
                hashlib.sha256((first / "policies.csv").read_bytes()).digest(),
                hashlib.sha256((third / "policies.csv").read_bytes()).digest(),
            )


if __name__ == "__main__":
    unittest.main()
