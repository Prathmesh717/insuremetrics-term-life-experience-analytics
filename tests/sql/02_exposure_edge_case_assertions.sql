\set ON_ERROR_STOP on

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM exposure_record
        WHERE policy_id = 1
          AND segment_start = DATE '2021-02-28'
          AND segment_end = DATE '2021-02-28'
          AND attained_age = 41
          AND duration_year = 2
    ) THEN
        RAISE EXCEPTION 'Leap-day anniversary was not assigned to duration 2';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM exposure_record
        WHERE policy_id = 2
          AND segment_start = DATE '2025-12-31'
          AND segment_end = DATE '2025-12-31'
          AND ABS(exposure - (1.0 / 365.0)) < 0.000000001
    ) THEN
        RAISE EXCEPTION 'Single-day year-end exposure is incorrect';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM exposure_record
        WHERE policy_id = 3
          AND segment_start = DATE '2023-06-15'
          AND duration_year = 2
          AND actual_death = 1
          AND actual_claim_amount = 500000
    ) THEN
        RAISE EXCEPTION 'Anniversary-date death was not assigned to duration 2';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM exposure_record
        WHERE policy_id = 4
          AND calendar_year = 2024
        GROUP BY policy_id, calendar_year
        HAVING ABS(SUM(exposure) - 1.0) < 0.000000001
    ) THEN
        RAISE EXCEPTION 'Full leap-year exposure does not equal one';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT
                policy_id,
                segment_start,
                LAG(segment_end) OVER (
                    PARTITION BY policy_id ORDER BY segment_start
                ) AS prior_end
            FROM exposure_record
        ) ordered
        WHERE prior_end IS NOT NULL
          AND segment_start <> prior_end + 1
    ) THEN
        RAISE EXCEPTION 'Exposure segments contain a gap or overlap';
    END IF;
END
$$;

SELECT 'exposure_edge_cases' AS test_suite, 'PASS' AS result;
