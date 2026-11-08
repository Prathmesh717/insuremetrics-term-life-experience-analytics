\set ON_ERROR_STOP on

DELETE FROM mortality_assumption
WHERE basis_name = 'TEST_BASIS'
  AND sex = 'M'
  AND smoker_status = 'NS'
  AND attained_age = 39
  AND duration_year = 1;
