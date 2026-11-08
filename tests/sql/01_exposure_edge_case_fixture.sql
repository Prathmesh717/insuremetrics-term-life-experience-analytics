\set ON_ERROR_STOP on

BEGIN;

INSERT INTO product (product_id, product_code, product_name, level_term_years)
VALUES (1, 'TEST', 'Test Product', 30);

INSERT INTO mortality_assumption (
    basis_name, sex, smoker_status, attained_age, duration_year, qx
)
SELECT
    'TEST_BASIS',
    'M',
    'NS',
    age,
    duration,
    0.010000000
FROM generate_series(39, 46) AS age
CROSS JOIN generate_series(1, 6) AS duration;

INSERT INTO policy (
    policy_id, product_id, issue_date, issue_age, sex, smoker_status,
    face_amount, issue_state, termination_date, termination_reason, policy_status
)
VALUES
    -- A leap-day issue must enter duration 2 on 28-Feb-2021.
    (1, 1, DATE '2020-02-29', 40, 'M', 'NS', 100000, 'TX',
     DATE '2021-02-28', 'LAPSE', 'TERMINATED'),
    -- One day of exposure at the end of the study.
    (2, 1, DATE '2025-12-31', 39, 'M', 'NS', 250000, 'TX',
     NULL, NULL, 'INFORCE'),
    -- Death exactly on an anniversary belongs to the new duration.
    (3, 1, DATE '2022-06-15', 41, 'M', 'NS', 500000, 'TX',
     DATE '2023-06-15', 'DEATH', 'TERMINATED'),
    -- Full leap-calendar-year exposure must equal one life-year.
    (4, 1, DATE '2020-01-01', 42, 'M', 'NS', 100000, 'TX',
     DATE '2024-12-31', 'LAPSE', 'TERMINATED');

INSERT INTO death_claim (
    claim_id, policy_id, date_of_death, report_date, paid_amount, claim_status
)
VALUES (1, 3, DATE '2023-06-15', DATE '2023-06-20', 500000, 'APPROVED');

INSERT INTO experience_study (
    study_name, study_start_date, study_end_date, basis_name, lapse_basis_name
)
VALUES (
    '2021-2025 Mortality Study', DATE '2021-01-01', DATE '2025-12-31',
    'TEST_BASIS', 'TEST_LAPSE_BASIS'
);

COMMIT;
