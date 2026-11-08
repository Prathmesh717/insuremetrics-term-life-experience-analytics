\set ON_ERROR_STOP on

-- Materialize every control so the script can print a compact report and then
-- fail the pipeline if any control is non-zero.
CREATE TEMP TABLE validation_result (
    check_name text PRIMARY KEY,
    failures bigint NOT NULL
);

INSERT INTO validation_result
SELECT 'orphan_claims', COUNT(*)
FROM death_claim dc LEFT JOIN policy p USING (policy_id)
WHERE p.policy_id IS NULL;

INSERT INTO validation_result
SELECT 'invalid_claim_dates', COUNT(*)
FROM death_claim dc JOIN policy p USING (policy_id)
WHERE dc.date_of_death < p.issue_date
   OR dc.report_date < dc.date_of_death
   OR dc.date_of_death > COALESCE(p.termination_date, dc.date_of_death);

INSERT INTO validation_result
SELECT 'death_policy_mismatch', COUNT(*)
FROM death_claim dc JOIN policy p USING (policy_id)
WHERE p.termination_reason <> 'DEATH'
   OR p.termination_date <> dc.date_of_death;

INSERT INTO validation_result
SELECT 'invalid_exposure', COUNT(*)
FROM exposure_record
WHERE exposure <= 0 OR exposure > 1.01 OR segment_end < segment_start;

INSERT INTO validation_result
SELECT 'segment_outside_study_window', COUNT(*)
FROM exposure_record er
JOIN experience_study s USING (study_id)
WHERE er.segment_start < s.study_start_date
   OR er.segment_end > s.study_end_date;

INSERT INTO validation_result
SELECT 'segment_outside_policy_window', COUNT(*)
FROM exposure_record er
JOIN policy p USING (policy_id)
WHERE er.segment_start < p.issue_date
   OR er.segment_end > COALESCE(p.termination_date, er.segment_end);

INSERT INTO validation_result
SELECT 'missing_assumption_match', COUNT(*)
FROM exposure_record
WHERE expected_qx IS NULL;

INSERT INTO validation_result
SELECT 'duplicate_policy_segment', COUNT(*)
FROM (
    SELECT study_id, policy_id, segment_start
    FROM exposure_record
    GROUP BY 1, 2, 3
    HAVING COUNT(*) > 1
) d;

INSERT INTO validation_result
SELECT 'overlapping_or_gapped_segments', COUNT(*)
FROM (
    SELECT
        study_id,
        policy_id,
        segment_start,
        LAG(segment_end) OVER (
            PARTITION BY study_id, policy_id ORDER BY segment_start
        ) AS prior_segment_end
    FROM exposure_record
) ordered
WHERE prior_segment_end IS NOT NULL
  AND segment_start <> prior_segment_end + 1;

INSERT INTO validation_result
SELECT 'expected_death_calculation', COUNT(*)
FROM exposure_record
WHERE ABS(expected_deaths - exposure * expected_qx) > 0.000000001;

INSERT INTO validation_result
SELECT 'expected_amount_calculation', COUNT(*)
FROM exposure_record er
JOIN policy p USING (policy_id)
WHERE ABS(er.expected_claim_amount - er.exposure * er.expected_qx * p.face_amount) > 0.01;

INSERT INTO validation_result
SELECT 'claims_vs_exposure_count', ABS(expected_count - actual_count)::bigint
FROM (
    SELECT
        (SELECT COUNT(*)
         FROM death_claim dc
         JOIN policy p USING (policy_id)
         JOIN experience_study s
           ON s.study_name = '2021-2025 Mortality Study'
          AND dc.date_of_death BETWEEN s.study_start_date AND s.study_end_date
         WHERE dc.claim_status = 'APPROVED'
           AND dc.date_of_death BETWEEN p.issue_date AND COALESCE(p.termination_date, dc.date_of_death)
        ) AS expected_count,
        (SELECT COALESCE(SUM(er.actual_death), 0)
         FROM exposure_record er
         JOIN experience_study s USING (study_id)
         WHERE s.study_name = '2021-2025 Mortality Study'
        ) AS actual_count
) totals;

INSERT INTO validation_result
SELECT 'claims_vs_exposure_amount',
       CASE WHEN ABS(expected_amount - actual_amount) <= 0.01 THEN 0 ELSE 1 END
FROM (
    SELECT
        (SELECT COALESCE(SUM(dc.paid_amount), 0)
         FROM death_claim dc
         JOIN policy p USING (policy_id)
         JOIN experience_study s
           ON s.study_name = '2021-2025 Mortality Study'
          AND dc.date_of_death BETWEEN s.study_start_date AND s.study_end_date
         WHERE dc.claim_status = 'APPROVED'
           AND dc.date_of_death BETWEEN p.issue_date AND COALESCE(p.termination_date, dc.date_of_death)
        ) AS expected_amount,
        (SELECT COALESCE(SUM(er.actual_claim_amount), 0)
         FROM exposure_record er
         JOIN experience_study s USING (study_id)
         WHERE s.study_name = '2021-2025 Mortality Study'
        ) AS actual_amount
) totals;

INSERT INTO validation_result
SELECT 'dimension_result_reconciliation', COUNT(*)
FROM (
    SELECT
        r.dimension_name
    FROM experience_result r
    JOIN experience_study s USING (study_id)
    WHERE s.study_name = '2021-2025 Mortality Study'
    GROUP BY r.study_id, r.dimension_name
    HAVING ABS(SUM(r.exposure) - (
               SELECT SUM(er.exposure)
               FROM exposure_record er
               WHERE er.study_id = r.study_id
           )) > 0.01
        OR SUM(r.actual_deaths) <> (
               SELECT SUM(er.actual_death)
               FROM exposure_record er
               WHERE er.study_id = r.study_id
           )
) mismatches;

INSERT INTO validation_result
SELECT 'lapse_exposure_spine_mismatch', COUNT(*)
FROM (
    SELECT
        COALESCE(er.study_id, ler.study_id) AS study_id,
        COALESCE(er.policy_id, ler.policy_id) AS policy_id,
        COALESCE(er.segment_start, ler.segment_start) AS segment_start
    FROM exposure_record er
    FULL OUTER JOIN lapse_exposure_record ler
      ON ler.study_id = er.study_id
     AND ler.policy_id = er.policy_id
     AND ler.segment_start = er.segment_start
    WHERE er.policy_id IS NULL
       OR ler.policy_id IS NULL
       OR er.segment_end <> ler.segment_end
       OR er.exposure <> ler.exposure
       OR er.duration_year <> ler.duration_year
) mismatches;

INSERT INTO validation_result
SELECT 'lapse_expected_calculation', COUNT(*)
FROM lapse_exposure_record
WHERE ABS(expected_lapses - exposure * expected_lapse_qx) > 0.000000001;

INSERT INTO validation_result
SELECT 'lapse_competing_termination', COUNT(*)
FROM lapse_exposure_record ler
JOIN policy p USING (policy_id)
WHERE ler.actual_lapse = 1
  AND (
      p.termination_reason <> 'LAPSE'
      OR p.termination_date NOT BETWEEN ler.segment_start AND ler.segment_end
  );

INSERT INTO validation_result
SELECT 'lapses_vs_exposure_count', ABS(expected_count - actual_count)::bigint
FROM (
    SELECT
        (SELECT COUNT(*)
         FROM policy p
         JOIN experience_study s
           ON s.study_name = '2021-2025 Mortality Study'
          AND p.termination_date BETWEEN s.study_start_date AND s.study_end_date
         WHERE p.termination_reason = 'LAPSE'
        ) AS expected_count,
        (SELECT COALESCE(SUM(ler.actual_lapse), 0)
         FROM lapse_exposure_record ler
         JOIN experience_study s USING (study_id)
         WHERE s.study_name = '2021-2025 Mortality Study'
        ) AS actual_count
) totals;

INSERT INTO validation_result
SELECT 'lapse_result_reconciliation', COUNT(*)
FROM (
    SELECT
        r.analysis_name
    FROM lapse_result r
    JOIN experience_study s USING (study_id)
    WHERE s.study_name = '2021-2025 Mortality Study'
      AND r.analysis_name <> 'portfolio'
    GROUP BY r.study_id, r.analysis_name
    HAVING ABS(SUM(r.exposure) - (
               SELECT SUM(ler.exposure)
               FROM lapse_exposure_record ler
               WHERE ler.study_id = r.study_id
           )) > 0.01
        OR SUM(r.actual_lapses) <> (
               SELECT SUM(ler.actual_lapse)
               FROM lapse_exposure_record ler
               WHERE ler.study_id = r.study_id
           )
) mismatches;

DELETE FROM study_validation_result
WHERE study_id = (
    SELECT study_id
    FROM experience_study
    WHERE study_name = '2021-2025 Mortality Study'
);

INSERT INTO study_validation_result (study_id, check_name, failures)
SELECT
    (
        SELECT study_id
        FROM experience_study
        WHERE study_name = '2021-2025 Mortality Study'
    ),
    check_name,
    failures
FROM validation_result;

TABLE validation_result ORDER BY check_name;

DO $$
DECLARE
    total_failures bigint;
    failed_checks text;
BEGIN
    SELECT COALESCE(SUM(failures), 0),
           STRING_AGG(check_name || '=' || failures, ', ' ORDER BY check_name)
               FILTER (WHERE failures > 0)
    INTO total_failures, failed_checks
    FROM validation_result;

    IF total_failures > 0 THEN
        RAISE EXCEPTION 'Experience-study validation failed: %', failed_checks;
    END IF;
END
$$;
