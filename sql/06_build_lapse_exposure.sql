\set ON_ERROR_STOP on

BEGIN;

TRUNCATE lapse_exposure_record;

-- Reuse the validated mortality exposure spine. Death, lapse, and maturity
-- terminations therefore compete for the same active policy time and no policy
-- can contribute exposure after its first termination event.
INSERT INTO lapse_exposure_record (
    study_id, policy_id, calendar_year, segment_start, segment_end, exposure,
    duration_year, expected_lapse_qx, expected_lapses, actual_lapse
)
SELECT
    er.study_id,
    er.policy_id,
    er.calendar_year,
    er.segment_start,
    er.segment_end,
    er.exposure,
    er.duration_year,
    la.lapse_qx,
    er.exposure * la.lapse_qx,
    CASE
        WHEN p.termination_reason = 'LAPSE'
         AND p.termination_date BETWEEN er.segment_start AND er.segment_end
        THEN 1
        ELSE 0
    END
FROM exposure_record er
JOIN experience_study s USING (study_id)
JOIN policy p USING (policy_id)
LEFT JOIN lapse_assumption la
  ON la.basis_name = s.lapse_basis_name
 AND la.product_id = p.product_id
 AND la.duration_year = LEAST(er.duration_year, 30);

COMMIT;
