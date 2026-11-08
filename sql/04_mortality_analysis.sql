\set ON_ERROR_STOP on

BEGIN;

TRUNCATE experience_result, mortality_result;

-- Compact one-dimensional result table for simple BI consumers.
WITH grouped AS (
    SELECT
        study_id,
        CASE
            WHEN GROUPING(sex) = 0 THEN 'sex'
            WHEN GROUPING(smoker_status) = 0 THEN 'smoker_status'
            WHEN GROUPING(product_code) = 0 THEN 'product'
            WHEN GROUPING(age_band) = 0 THEN 'attained_age_band'
            WHEN GROUPING(duration_band) = 0 THEN 'duration_band'
        END AS dimension_name,
        COALESCE(sex, smoker_status, product_code, age_band, duration_band) AS dimension_value,
        SUM(exposure) AS exposure,
        SUM(actual_death)::bigint AS actual_deaths,
        SUM(expected_deaths) AS expected_deaths,
        SUM(actual_claim_amount) AS actual_claim_amount,
        SUM(expected_claim_amount) AS expected_claim_amount
    FROM mortality_experience_detail
    GROUP BY study_id, GROUPING SETS (
        (sex), (smoker_status), (product_code), (age_band), (duration_band)
    )
)
INSERT INTO experience_result (
    study_id, dimension_name, dimension_value, exposure, actual_deaths,
    expected_deaths, count_ae_ratio, actual_claim_amount,
    expected_claim_amount, amount_ae_ratio
)
SELECT
    study_id,
    dimension_name,
    dimension_value,
    exposure,
    actual_deaths,
    expected_deaths,
    actual_deaths / NULLIF(expected_deaths, 0),
    actual_claim_amount,
    expected_claim_amount,
    actual_claim_amount / NULLIF(expected_claim_amount, 0)
FROM grouped;

-- Decision-oriented result mart. Cross-segment rows support trend analysis,
-- heatmaps, count-vs-amount investigation, and targeted recommendations.
WITH aggregate_rows AS (
    SELECT
        study_id,
        'portfolio'::text AS analysis_name,
        'portfolio'::text AS dimension_1_name,
        'All'::text AS dimension_1_value,
        ''::text AS dimension_2_name,
        ''::text AS dimension_2_value,
        SUM(exposure) AS exposure,
        SUM(actual_death)::bigint AS actual_deaths,
        SUM(expected_deaths) AS expected_deaths,
        SUM(actual_claim_amount) AS actual_claim_amount,
        SUM(expected_claim_amount) AS expected_claim_amount,
        SUM(large_claim)::bigint AS large_claim_count
    FROM mortality_experience_detail
    GROUP BY study_id

    UNION ALL
    SELECT
        study_id, 'calendar_year', 'calendar_year', calendar_year::text, '', '',
        SUM(exposure), SUM(actual_death)::bigint, SUM(expected_deaths),
        SUM(actual_claim_amount), SUM(expected_claim_amount), SUM(large_claim)::bigint
    FROM mortality_experience_detail
    GROUP BY study_id, calendar_year

    UNION ALL
    SELECT
        study_id, 'issue_cohort', 'issue_cohort', issue_cohort, '', '',
        SUM(exposure), SUM(actual_death)::bigint, SUM(expected_deaths),
        SUM(actual_claim_amount), SUM(expected_claim_amount), SUM(large_claim)::bigint
    FROM mortality_experience_detail
    GROUP BY study_id, issue_cohort

    UNION ALL
    SELECT
        study_id, 'sex_smoker', 'sex', sex::text, 'smoker_status', smoker_status,
        SUM(exposure), SUM(actual_death)::bigint, SUM(expected_deaths),
        SUM(actual_claim_amount), SUM(expected_claim_amount), SUM(large_claim)::bigint
    FROM mortality_experience_detail
    GROUP BY study_id, sex, smoker_status

    UNION ALL
    SELECT
        study_id, 'age_duration', 'attained_age_band', age_band,
        'duration_band', duration_band,
        SUM(exposure), SUM(actual_death)::bigint, SUM(expected_deaths),
        SUM(actual_claim_amount), SUM(expected_claim_amount), SUM(large_claim)::bigint
    FROM mortality_experience_detail
    GROUP BY study_id, age_band, duration_band

    UNION ALL
    SELECT
        study_id, 'product_face_amount', 'product', product_code,
        'face_amount_band', face_amount_band,
        SUM(exposure), SUM(actual_death)::bigint, SUM(expected_deaths),
        SUM(actual_claim_amount), SUM(expected_claim_amount), SUM(large_claim)::bigint
    FROM mortality_experience_detail
    GROUP BY study_id, product_code, face_amount_band

    UNION ALL
    SELECT
        study_id, 'state', 'issue_state', issue_state, '', '',
        SUM(exposure), SUM(actual_death)::bigint, SUM(expected_deaths),
        SUM(actual_claim_amount), SUM(expected_claim_amount), SUM(large_claim)::bigint
    FROM mortality_experience_detail
    GROUP BY study_id, issue_state
), raw_metrics AS (
    SELECT
        a.*,
        actual_deaths / NULLIF(expected_deaths, 0) AS count_ae_ratio,
        actual_claim_amount / NULLIF(expected_claim_amount, 0) AS amount_ae_ratio,
        actual_deaths - expected_deaths AS excess_deaths,
        actual_claim_amount - expected_claim_amount AS claim_amount_variance,
        LEAST(1.0, SQRT(actual_deaths / 384.16)) AS credibility,
        CASE
            WHEN actual_deaths = 0 THEN 0.0
            ELSE actual_deaths
                 * POWER(
                     GREATEST(
                         0.0,
                         1.0 - 1.0 / (9.0 * actual_deaths)
                             - 1.96 / (3.0 * SQRT(actual_deaths))
                     ),
                     3
                 )
        END AS death_lower_95,
        CASE
            WHEN actual_deaths = 0 THEN -LN(0.025)
            ELSE (actual_deaths + 1)
                 * POWER(
                     1.0 - 1.0 / (9.0 * (actual_deaths + 1))
                         + 1.96 / (3.0 * SQRT(actual_deaths + 1)),
                     3
                 )
        END AS death_upper_95
    FROM aggregate_rows a
), governed AS (
    SELECT
        r.*,
        death_lower_95 / NULLIF(expected_deaths, 0) AS count_ae_lower_95,
        death_upper_95 / NULLIF(expected_deaths, 0) AS count_ae_upper_95,
        1.0 + credibility * (count_ae_ratio - 1.0) AS credible_count_ae
    FROM raw_metrics r
)
INSERT INTO mortality_result (
    study_id, analysis_name, dimension_1_name, dimension_1_value,
    dimension_2_name, dimension_2_value, exposure, actual_deaths,
    expected_deaths, count_ae_ratio, count_ae_lower_95,
    count_ae_upper_95, credibility, credible_count_ae,
    actual_claim_amount, expected_claim_amount, amount_ae_ratio,
    excess_deaths, claim_amount_variance, large_claim_count,
    recommended_action
)
SELECT
    study_id,
    analysis_name,
    dimension_1_name,
    dimension_1_value,
    dimension_2_name,
    dimension_2_value,
    exposure,
    actual_deaths,
    expected_deaths,
    count_ae_ratio,
    count_ae_lower_95,
    count_ae_upper_95,
    credibility,
    credible_count_ae,
    actual_claim_amount,
    expected_claim_amount,
    amount_ae_ratio,
    excess_deaths,
    claim_amount_variance,
    large_claim_count,
    CASE
        WHEN exposure < 250 OR actual_deaths < 5 THEN 'LOW_CREDIBILITY'
        WHEN count_ae_lower_95 > 1.0 AND credible_count_ae >= 1.10 THEN 'STRENGTHEN_ASSUMPTION'
        WHEN count_ae_upper_95 < 1.0 AND credible_count_ae <= 0.90 THEN 'WEAKEN_ASSUMPTION'
        WHEN ABS(credible_count_ae - 1.0) >= 0.05 THEN 'MONITOR'
        ELSE 'MAINTAIN'
    END
FROM governed;

COMMIT;

SELECT
    ROUND(exposure, 2) AS life_years,
    actual_deaths,
    ROUND(expected_deaths, 2) AS expected_deaths,
    ROUND(100 * count_ae_ratio, 1) AS count_ae_pct,
    ROUND(100 * count_ae_lower_95, 1) AS count_ae_lower_95_pct,
    ROUND(100 * count_ae_upper_95, 1) AS count_ae_upper_95_pct,
    ROUND(100 * credibility, 1) AS credibility_pct,
    ROUND(100 * credible_count_ae, 1) AS credible_ae_pct,
    ROUND(100 * amount_ae_ratio, 1) AS amount_ae_pct,
    recommended_action
FROM mortality_result
WHERE analysis_name = 'portfolio';

SELECT
    analysis_name,
    dimension_1_value,
    NULLIF(dimension_2_value, '') AS dimension_2_value,
    ROUND(exposure, 1) AS exposure,
    actual_deaths,
    ROUND(100 * count_ae_ratio, 1) AS count_ae_pct,
    ROUND(100 * amount_ae_ratio, 1) AS amount_ae_pct,
    ROUND(excess_deaths, 2) AS excess_deaths,
    recommended_action
FROM mortality_result
WHERE analysis_name <> 'portfolio'
  AND exposure >= 250
ORDER BY excess_deaths DESC
LIMIT 15;
