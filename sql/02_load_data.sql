\set ON_ERROR_STOP on

BEGIN;
TRUNCATE death_claim, lapse_assumption, mortality_assumption, policy, product RESTART IDENTITY CASCADE;

\copy product(product_id, product_code, product_name, level_term_years) FROM '/data/products.csv' WITH (FORMAT csv, HEADER true)
\copy mortality_assumption(basis_name, sex, smoker_status, attained_age, duration_year, qx) FROM '/data/mortality_assumptions.csv' WITH (FORMAT csv, HEADER true)
\copy lapse_assumption(basis_name, product_id, duration_year, lapse_qx) FROM '/data/lapse_assumptions.csv' WITH (FORMAT csv, HEADER true)
\copy policy(policy_id, product_id, issue_date, issue_age, sex, smoker_status, face_amount, issue_state, termination_date, termination_reason, policy_status) FROM '/data/policies.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy death_claim(claim_id, policy_id, date_of_death, report_date, paid_amount, claim_status) FROM '/data/death_claims.csv' WITH (FORMAT csv, HEADER true)

INSERT INTO experience_study (
    study_name, study_start_date, study_end_date, basis_name, lapse_basis_name
)
VALUES (
    '2021-2025 Mortality Study', DATE '2021-01-01', DATE '2025-12-31',
    'LSL_2020_FICTIONAL', 'LSL_2020_LAPSE_FICTIONAL'
)
ON CONFLICT (study_name) DO UPDATE
SET study_start_date = EXCLUDED.study_start_date,
    study_end_date = EXCLUDED.study_end_date,
    basis_name = EXCLUDED.basis_name,
    lapse_basis_name = EXCLUDED.lapse_basis_name;
COMMIT;
