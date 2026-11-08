\set ON_ERROR_STOP on

BEGIN;
TRUNCATE exposure_record;

WITH study AS (
    SELECT * FROM experience_study WHERE study_name = '2021-2025 Mortality Study'
), active_policies AS (
    SELECT
        s.study_id,
        s.basis_name,
        p.*,
        GREATEST(p.issue_date, s.study_start_date) AS active_start,
        LEAST(COALESCE(p.termination_date, s.study_end_date), s.study_end_date) AS active_end
    FROM study s
    JOIN policy p
      ON p.issue_date <= s.study_end_date
     AND COALESCE(p.termination_date, s.study_end_date) >= s.study_start_date
), boundaries AS (
    SELECT ap.*, boundary_date
    FROM active_policies ap
    CROSS JOIN LATERAL (
        SELECT ap.active_start AS boundary_date
        UNION
        SELECT ap.active_end + 1
        UNION
        SELECT gs::date
        FROM generate_series(
            date_trunc('year', ap.active_start) + interval '1 year',
            ap.active_end,
            interval '1 year'
        ) gs
        UNION
        SELECT (ap.issue_date + (n || ' years')::interval)::date
        FROM generate_series(1, 50) n
        WHERE (ap.issue_date + (n || ' years')::interval)::date > ap.active_start
          AND (ap.issue_date + (n || ' years')::interval)::date <= ap.active_end
    ) b
), ordered_boundaries AS (
    SELECT
        b.*,
        LEAD(boundary_date) OVER (PARTITION BY study_id, policy_id ORDER BY boundary_date) AS next_boundary
    FROM boundaries b
), segments AS (
    SELECT
        ob.*,
        ob.boundary_date AS segment_start,
        ob.next_boundary - 1 AS segment_end,
        ob.issue_age + anniversary.completed_years AS attained_age,
        anniversary.completed_years + 1 AS duration_year
    FROM ordered_boundaries ob
    CROSS JOIN LATERAL (
        -- age() treats 28-Feb following a leap-day issue as less than one
        -- completed year. Compare with the policy anniversary explicitly so
        -- leap-day policies move to the next duration on 28-Feb.
        SELECT (
            EXTRACT(YEAR FROM ob.boundary_date)::int
            - EXTRACT(YEAR FROM ob.issue_date)::int
            - CASE
                WHEN ob.boundary_date < (
                    ob.issue_date
                    + ((EXTRACT(YEAR FROM ob.boundary_date)::int
                        - EXTRACT(YEAR FROM ob.issue_date)::int) || ' years')::interval
                )::date THEN 1
                ELSE 0
              END
        )::smallint AS completed_years
    ) anniversary
    WHERE ob.next_boundary IS NOT NULL
), valued AS (
    SELECT
        sg.*,
        ((sg.segment_end - sg.segment_start + 1)::numeric /
          (make_date(EXTRACT(YEAR FROM sg.segment_start)::int + 1, 1, 1)
           - make_date(EXTRACT(YEAR FROM sg.segment_start)::int, 1, 1))) AS exposure,
        ma.qx AS expected_qx,
        CASE WHEN dc.claim_status = 'APPROVED'
                   AND dc.date_of_death BETWEEN sg.segment_start AND sg.segment_end THEN 1 ELSE 0 END AS actual_death,
        CASE WHEN dc.claim_status = 'APPROVED'
                   AND dc.date_of_death BETWEEN sg.segment_start AND sg.segment_end THEN dc.paid_amount ELSE 0 END AS actual_claim_amount
    FROM segments sg
    -- Preserve the exposure row when an assumption is missing. The NOT NULL
    -- constraints on exposure_record then fail the build instead of silently
    -- dropping policy exposure through an inner join.
    LEFT JOIN mortality_assumption ma
      ON ma.basis_name = sg.basis_name
     AND ma.sex = sg.sex
     AND ma.smoker_status = sg.smoker_status
     AND ma.attained_age = sg.attained_age
     AND ma.duration_year = LEAST(sg.duration_year, 6)
    LEFT JOIN death_claim dc ON dc.policy_id = sg.policy_id
    WHERE sg.segment_end >= sg.segment_start
)
INSERT INTO exposure_record (
    study_id, policy_id, calendar_year, segment_start, segment_end, exposure,
    attained_age, duration_year, expected_qx, expected_deaths, actual_death,
    expected_claim_amount, actual_claim_amount
)
SELECT
    study_id,
    policy_id,
    EXTRACT(YEAR FROM segment_start)::smallint,
    segment_start,
    segment_end,
    exposure,
    attained_age,
    duration_year,
    expected_qx,
    exposure * expected_qx,
    actual_death,
    exposure * expected_qx * face_amount,
    actual_claim_amount
FROM valued;

COMMIT;
