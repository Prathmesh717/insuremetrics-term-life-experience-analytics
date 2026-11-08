BEGIN;

DROP VIEW IF EXISTS mortality_experience_detail CASCADE;
DROP TABLE IF EXISTS study_validation_result CASCADE;
DROP TABLE IF EXISTS lapse_result CASCADE;
DROP TABLE IF EXISTS lapse_exposure_record CASCADE;
DROP TABLE IF EXISTS lapse_assumption CASCADE;
DROP TABLE IF EXISTS mortality_result CASCADE;
DROP TABLE IF EXISTS experience_result CASCADE;
DROP TABLE IF EXISTS exposure_record CASCADE;
DROP TABLE IF EXISTS experience_study CASCADE;
DROP TABLE IF EXISTS death_claim CASCADE;
DROP TABLE IF EXISTS mortality_assumption CASCADE;
DROP TABLE IF EXISTS policy CASCADE;
DROP TABLE IF EXISTS product CASCADE;

CREATE TABLE product (
    product_id          integer PRIMARY KEY,
    product_code        text NOT NULL UNIQUE,
    product_name        text NOT NULL,
    level_term_years    smallint NOT NULL CHECK (level_term_years > 0)
);

CREATE TABLE policy (
    policy_id           bigint PRIMARY KEY,
    product_id          integer NOT NULL REFERENCES product(product_id),
    issue_date          date NOT NULL,
    issue_age           smallint NOT NULL CHECK (issue_age BETWEEN 18 AND 80),
    sex                 char(1) NOT NULL CHECK (sex IN ('M', 'F')),
    smoker_status       varchar(2) NOT NULL CHECK (smoker_status IN ('NS', 'SM')),
    face_amount         numeric(14,2) NOT NULL CHECK (face_amount > 0),
    issue_state         char(2) NOT NULL,
    termination_date    date,
    termination_reason  varchar(10) CHECK (termination_reason IN ('DEATH', 'LAPSE', 'MATURITY')),
    policy_status       varchar(10) NOT NULL CHECK (policy_status IN ('INFORCE', 'TERMINATED')),
    CHECK (termination_date IS NULL OR termination_date >= issue_date),
    CHECK ((policy_status = 'INFORCE' AND termination_date IS NULL AND termination_reason IS NULL)
        OR (policy_status = 'TERMINATED' AND termination_date IS NOT NULL AND termination_reason IS NOT NULL))
);

CREATE TABLE mortality_assumption (
    mortality_assumption_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    basis_name          text NOT NULL,
    sex                 char(1) NOT NULL CHECK (sex IN ('M', 'F')),
    smoker_status       varchar(2) NOT NULL CHECK (smoker_status IN ('NS', 'SM')),
    attained_age        smallint NOT NULL CHECK (attained_age BETWEEN 18 AND 120),
    duration_year       smallint NOT NULL CHECK (duration_year BETWEEN 1 AND 6),
    qx                  numeric(12,9) NOT NULL CHECK (qx > 0 AND qx < 1),
    UNIQUE (basis_name, sex, smoker_status, attained_age, duration_year)
);

CREATE TABLE lapse_assumption (
    lapse_assumption_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    basis_name          text NOT NULL,
    product_id          integer NOT NULL REFERENCES product(product_id),
    duration_year       smallint NOT NULL CHECK (duration_year BETWEEN 1 AND 50),
    lapse_qx            numeric(12,9) NOT NULL CHECK (lapse_qx > 0 AND lapse_qx < 1),
    UNIQUE (basis_name, product_id, duration_year)
);

CREATE TABLE death_claim (
    claim_id            bigint PRIMARY KEY,
    policy_id           bigint NOT NULL UNIQUE REFERENCES policy(policy_id),
    date_of_death       date NOT NULL,
    report_date         date NOT NULL,
    paid_amount         numeric(14,2) NOT NULL CHECK (paid_amount >= 0),
    claim_status        varchar(10) NOT NULL CHECK (claim_status IN ('APPROVED', 'DENIED', 'PENDING')),
    CHECK (report_date >= date_of_death)
);

CREATE TABLE experience_study (
    study_id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    study_name          text NOT NULL UNIQUE,
    study_start_date    date NOT NULL,
    study_end_date      date NOT NULL,
    basis_name          text NOT NULL,
    lapse_basis_name    text NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT current_timestamp,
    CHECK (study_end_date >= study_start_date)
);

CREATE TABLE exposure_record (
    study_id            bigint NOT NULL REFERENCES experience_study(study_id),
    policy_id           bigint NOT NULL REFERENCES policy(policy_id),
    calendar_year       smallint NOT NULL,
    segment_start       date NOT NULL,
    segment_end         date NOT NULL,
    exposure            numeric(12,9) NOT NULL CHECK (exposure > 0 AND exposure <= 1.01),
    attained_age        smallint NOT NULL,
    duration_year       smallint NOT NULL,
    expected_qx         numeric(12,9) NOT NULL,
    expected_deaths     numeric(16,9) NOT NULL,
    actual_death        smallint NOT NULL CHECK (actual_death IN (0, 1)),
    expected_claim_amount numeric(18,4) NOT NULL,
    actual_claim_amount numeric(18,2) NOT NULL,
    PRIMARY KEY (study_id, policy_id, segment_start),
    CHECK (segment_end >= segment_start)
);

CREATE TABLE experience_result (
    study_id            bigint NOT NULL REFERENCES experience_study(study_id),
    dimension_name      text NOT NULL,
    dimension_value     text NOT NULL,
    exposure            numeric(18,6) NOT NULL,
    actual_deaths       bigint NOT NULL,
    expected_deaths     numeric(18,6) NOT NULL,
    count_ae_ratio      numeric(12,6),
    actual_claim_amount numeric(20,2) NOT NULL,
    expected_claim_amount numeric(20,2) NOT NULL,
    amount_ae_ratio     numeric(12,6),
    calculated_at       timestamptz NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (study_id, dimension_name, dimension_value)
);

CREATE TABLE mortality_result (
    study_id              bigint NOT NULL REFERENCES experience_study(study_id),
    analysis_name         text NOT NULL,
    dimension_1_name      text NOT NULL,
    dimension_1_value     text NOT NULL,
    dimension_2_name      text NOT NULL DEFAULT '',
    dimension_2_value     text NOT NULL DEFAULT '',
    exposure              numeric(18,6) NOT NULL,
    actual_deaths         bigint NOT NULL,
    expected_deaths       numeric(18,6) NOT NULL,
    count_ae_ratio        numeric(12,6),
    count_ae_lower_95     numeric(12,6),
    count_ae_upper_95     numeric(12,6),
    credibility           numeric(12,6) NOT NULL,
    credible_count_ae     numeric(12,6),
    actual_claim_amount   numeric(20,2) NOT NULL,
    expected_claim_amount numeric(20,2) NOT NULL,
    amount_ae_ratio       numeric(12,6),
    excess_deaths         numeric(18,6) NOT NULL,
    claim_amount_variance numeric(20,2) NOT NULL,
    large_claim_count     bigint NOT NULL,
    recommended_action    text NOT NULL,
    calculated_at         timestamptz NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (
        study_id, analysis_name, dimension_1_value, dimension_2_value
    )
);

CREATE TABLE lapse_exposure_record (
    study_id            bigint NOT NULL REFERENCES experience_study(study_id),
    policy_id           bigint NOT NULL REFERENCES policy(policy_id),
    calendar_year       smallint NOT NULL,
    segment_start       date NOT NULL,
    segment_end         date NOT NULL,
    exposure            numeric(12,9) NOT NULL CHECK (exposure > 0 AND exposure <= 1.01),
    duration_year       smallint NOT NULL,
    expected_lapse_qx   numeric(12,9) NOT NULL,
    expected_lapses     numeric(16,9) NOT NULL,
    actual_lapse        smallint NOT NULL CHECK (actual_lapse IN (0, 1)),
    PRIMARY KEY (study_id, policy_id, segment_start),
    CHECK (segment_end >= segment_start)
);

CREATE TABLE lapse_result (
    study_id              bigint NOT NULL REFERENCES experience_study(study_id),
    analysis_name         text NOT NULL,
    dimension_1_name      text NOT NULL,
    dimension_1_value     text NOT NULL,
    dimension_2_name      text NOT NULL DEFAULT '',
    dimension_2_value     text NOT NULL DEFAULT '',
    exposure              numeric(18,6) NOT NULL,
    actual_lapses         bigint NOT NULL,
    expected_lapses       numeric(18,6) NOT NULL,
    lapse_ae_ratio        numeric(12,6),
    lapse_ae_lower_95     numeric(12,6),
    lapse_ae_upper_95     numeric(12,6),
    credibility           numeric(12,6) NOT NULL,
    credible_lapse_ae     numeric(12,6),
    excess_lapses         numeric(18,6) NOT NULL,
    recommended_action    text NOT NULL,
    calculated_at         timestamptz NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (
        study_id, analysis_name, dimension_1_value, dimension_2_value
    )
);

CREATE TABLE study_validation_result (
    study_id      bigint NOT NULL REFERENCES experience_study(study_id),
    check_name    text NOT NULL,
    failures      bigint NOT NULL,
    checked_at    timestamptz NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (study_id, check_name)
);

CREATE VIEW mortality_experience_detail AS
SELECT
    er.*,
    p.issue_date,
    p.issue_age,
    p.sex,
    p.smoker_status,
    p.face_amount,
    p.issue_state,
    pr.product_code,
    CASE
        WHEN p.issue_date < DATE '2019-01-01' THEN '2016-2018'
        WHEN p.issue_date < DATE '2022-01-01' THEN '2019-2021'
        ELSE '2022-2025'
    END AS issue_cohort,
    CASE
        WHEN er.attained_age < 35 THEN '<35'
        WHEN er.attained_age < 45 THEN '35-44'
        WHEN er.attained_age < 55 THEN '45-54'
        WHEN er.attained_age < 65 THEN '55-64'
        ELSE '65+'
    END AS age_band,
    CASE
        WHEN er.duration_year = 1 THEN '01'
        WHEN er.duration_year BETWEEN 2 AND 5 THEN '02-05'
        ELSE '06+'
    END AS duration_band,
    CASE
        WHEN p.face_amount < 250000 THEN '<250K'
        WHEN p.face_amount < 500000 THEN '250K-499K'
        WHEN p.face_amount < 750000 THEN '500K-749K'
        ELSE '750K+'
    END AS face_amount_band,
    CASE WHEN er.actual_claim_amount >= 750000 THEN 1 ELSE 0 END AS large_claim
FROM exposure_record er
JOIN policy p USING (policy_id)
JOIN product pr USING (product_id);

CREATE INDEX idx_policy_issue_termination ON policy(issue_date, termination_date);
CREATE INDEX idx_policy_rating ON policy(sex, smoker_status, product_id);
CREATE INDEX idx_mortality_lookup ON mortality_assumption(basis_name, sex, smoker_status, attained_age, duration_year);
CREATE INDEX idx_lapse_lookup ON lapse_assumption(basis_name, product_id, duration_year);
CREATE INDEX idx_claim_death_date ON death_claim(date_of_death);
CREATE INDEX idx_exposure_dimensions ON exposure_record(study_id, attained_age, duration_year);
CREATE INDEX idx_exposure_policy_year ON exposure_record(study_id, policy_id, calendar_year);
CREATE INDEX idx_mortality_result_analysis ON mortality_result(study_id, analysis_name);
CREATE INDEX idx_lapse_exposure_policy_year ON lapse_exposure_record(study_id, policy_id, calendar_year);
CREATE INDEX idx_lapse_result_analysis ON lapse_result(study_id, analysis_name);

COMMIT;
