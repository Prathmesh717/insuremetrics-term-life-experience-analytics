#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
policy_count="${POLICY_COUNT:-20000}"
random_seed="${STUDY_SEED:-20260828}"

cd "$project_dir"

echo "[1/10] Generating reproducible synthetic data"
python3 src/generate_data.py --policies "$policy_count" --seed "$random_seed"

echo "[2/10] Starting PostgreSQL"
docker compose up -d --wait db

run_sql() {
    local sql_file="$1"
    docker compose exec -T db \
        psql -v ON_ERROR_STOP=1 -U actuarial -d life_experience \
        -f /dev/stdin < "$sql_file"
}

echo "[3/10] Rebuilding database schema"
run_sql sql/01_schema.sql

echo "[4/10] Loading source data"
run_sql sql/02_load_data.sql

echo "[5/10] Building mortality policy-year exposure"
run_sql sql/03_build_exposure.sql

echo "[6/10] Calculating mortality results"
run_sql sql/04_mortality_analysis.sql

echo "[7/10] Building lapse exposure"
run_sql sql/06_build_lapse_exposure.sql

echo "[8/10] Calculating lapse results"
run_sql sql/07_lapse_analysis.sql

echo "[9/10] Running fail-fast validation controls"
run_sql sql/05_validation.sql

echo "[10/10] Exporting portable dashboard results"
./scripts/export_results.sh

echo "Study pipeline completed successfully."
