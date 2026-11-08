#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

docker compose up -d --wait db

run_sql() {
    local sql_file="$1"
    docker compose exec -T db \
        psql -v ON_ERROR_STOP=1 -U actuarial -d life_experience \
        -f /dev/stdin < "$sql_file"
}

echo "[1/5] Creating isolated edge-case fixture"
run_sql sql/01_schema.sql
run_sql tests/sql/01_exposure_edge_case_fixture.sql

echo "[2/5] Building fixture exposure"
run_sql sql/03_build_exposure.sql

echo "[3/5] Checking exposure edge cases"
run_sql tests/sql/02_exposure_edge_case_assertions.sql

echo "[4/5] Confirming a missing assumption fails the build"
run_sql tests/sql/03_remove_required_assumption.sql
if run_sql sql/03_build_exposure.sql; then
    echo "ERROR: exposure build succeeded despite a missing assumption" >&2
    exit 1
else
    echo "Missing-assumption fail-fast control passed"
fi

echo "[5/5] SQL integration tests passed"
