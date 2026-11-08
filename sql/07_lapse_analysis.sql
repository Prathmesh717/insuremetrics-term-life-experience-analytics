\set ON_ERROR_STOP on

BEGIN;

TRUNCATE lapse_result;

WITH detail AS (
    SELECT
        ler.*,
        p.face_amount,
        pr.product_code,
        CASE
            WHEN ler.duration_year = 1 THEN '01'
            WHEN ler.duration_year BETWEEN 2 AND 5 THEN '02-05'
            ELSE '06+'
        END AS duration_band,
        CASE
            WHEN p.face_amount < 250000 THEN '<250K'
            WHEN p.face_amount < 500000 THEN '250K-499K'
            WHEN p.face_amount < 750000 THEN '500K-749K'
            ELSE '750K+'
        END AS face_amount_band
    FROM lapse_exposure_record ler
    JOIN policy p USING (policy_id)
    JOIN product pr USING (product_id)
), aggregate_rows AS (
    SELECT
        study_id,
        'portfolio'::text AS analysis_name,
        'portfolio'::text AS dimension_1_name,
        'All'::text AS dimension_1_value,
        ''::text AS dimension_2_name,
        ''::text AS dimension_2_value,
        SUM(exposure) AS exposure,
        SUM(actual_lapse)::bigint AS actual_lapses,
        SUM(expected_lapses) AS expected_lapses
    FROM detail
    GROUP BY study_id

    UNION ALL
    SELECT
        study_id, 'calendar_year', 'calendar_year', calendar_year::text, '', '',
        SUM(exposure), SUM(actual_lapse)::bigint, SUM(expected_lapses)
    FROM detail
    GROUP BY study_id, calendar_year

    UNION ALL
    SELECT
        study_id, 'duration', 'duration_band', duration_band, '', '',
        SUM(exposure), SUM(actual_lapse)::bigint, SUM(expected_lapses)
    FROM detail
    GROUP BY study_id, duration_band

    UNION ALL
    SELECT
        study_id, 'product', 'product', product_code, '', '',
        SUM(exposure), SUM(actual_lapse)::bigint, SUM(expected_lapses)
    FROM detail
    GROUP BY study_id, product_code

    UNION ALL
    SELECT
        study_id, 'product_duration', 'product', product_code,
        'duration_band', duration_band,
        SUM(exposure), SUM(actual_lapse)::bigint, SUM(expected_lapses)
    FROM detail
    GROUP BY study_id, product_code, duration_band

    UNION ALL
    SELECT
        study_id, 'face_amount', 'face_amount_band', face_amount_band, '', '',
        SUM(exposure), SUM(actual_lapse)::bigint, SUM(expected_lapses)
    FROM detail
    GROUP BY study_id, face_amount_band
), raw_metrics AS (
    SELECT
        a.*,
        actual_lapses / NULLIF(expected_lapses, 0) AS lapse_ae_ratio,
        actual_lapses - expected_lapses AS excess_lapses,
        LEAST(1.0, SQRT(actual_lapses / 384.16)) AS credibility,
        CASE
            WHEN actual_lapses = 0 THEN 0.0
            ELSE actual_lapses
                 * POWER(
                     GREATEST(
                         0.0,
                         1.0 - 1.0 / (9.0 * actual_lapses)
                             - 1.96 / (3.0 * SQRT(actual_lapses))
                     ),
                     3
                 )
        END AS lapse_lower_95,
        CASE
            WHEN actual_lapses = 0 THEN -LN(0.025)
            ELSE (actual_lapses + 1)
                 * POWER(
                     1.0 - 1.0 / (9.0 * (actual_lapses + 1))
                         + 1.96 / (3.0 * SQRT(actual_lapses + 1)),
                     3
                 )
        END AS lapse_upper_95
    FROM aggregate_rows a
), governed AS (
    SELECT
        r.*,
        lapse_lower_95 / NULLIF(expected_lapses, 0) AS lapse_ae_lower_95,
        lapse_upper_95 / NULLIF(expected_lapses, 0) AS lapse_ae_upper_95,
        1.0 + credibility * (lapse_ae_ratio - 1.0) AS credible_lapse_ae
    FROM raw_metrics r
)
INSERT INTO lapse_result (
    study_id, analysis_name, dimension_1_name, dimension_1_value,
    dimension_2_name, dimension_2_value, exposure, actual_lapses,
    expected_lapses, lapse_ae_ratio, lapse_ae_lower_95,
    lapse_ae_upper_95, credibility, credible_lapse_ae, excess_lapses,
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
    actual_lapses,
    expected_lapses,
    lapse_ae_ratio,
    lapse_ae_lower_95,
    lapse_ae_upper_95,
    credibility,
    credible_lapse_ae,
    excess_lapses,
    CASE
        WHEN exposure < 250 OR actual_lapses < 5 THEN 'LOW_CREDIBILITY'
        WHEN lapse_ae_lower_95 > 1.0 AND credible_lapse_ae >= 1.10 THEN 'STRENGTHEN_LAPSE_ASSUMPTION'
        WHEN lapse_ae_upper_95 < 1.0 AND credible_lapse_ae <= 0.90 THEN 'WEAKEN_LAPSE_ASSUMPTION'
        WHEN ABS(credible_lapse_ae - 1.0) >= 0.05 THEN 'MONITOR'
        ELSE 'MAINTAIN'
    END
FROM governed;

COMMIT;

SELECT
    ROUND(exposure, 2) AS life_years,
    actual_lapses,
    ROUND(expected_lapses, 2) AS expected_lapses,
    ROUND(100 * lapse_ae_ratio, 1) AS lapse_ae_pct,
    ROUND(100 * lapse_ae_lower_95, 1) AS lapse_ae_lower_95_pct,
    ROUND(100 * lapse_ae_upper_95, 1) AS lapse_ae_upper_95_pct,
    ROUND(100 * credibility, 1) AS credibility_pct,
    ROUND(100 * credible_lapse_ae, 1) AS credible_lapse_ae_pct,
    recommended_action
FROM lapse_result
WHERE analysis_name = 'portfolio';

SELECT
    analysis_name,
    dimension_1_value,
    NULLIF(dimension_2_value, '') AS dimension_2_value,
    ROUND(exposure, 1) AS exposure,
    actual_lapses,
    ROUND(100 * lapse_ae_ratio, 1) AS lapse_ae_pct,
    ROUND(excess_lapses, 1) AS excess_lapses,
    recommended_action
FROM lapse_result
WHERE analysis_name <> 'portfolio'
ORDER BY ABS(excess_lapses) DESC
LIMIT 12;
