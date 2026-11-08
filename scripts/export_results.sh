#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$project_dir/data/outputs"
mkdir -p "$output_dir"
cd "$project_dir"

export_query() {
    local query="$1"
    local output_file="$2"
    docker compose exec -T db \
        psql -q --csv -U actuarial -d life_experience -c "$query" \
        > "$output_dir/$output_file"
}

export_query \
    "SELECT * FROM mortality_result ORDER BY analysis_name, dimension_1_value, dimension_2_value" \
    "mortality_results.csv"
export_query \
    "SELECT * FROM lapse_result ORDER BY analysis_name, dimension_1_value, dimension_2_value" \
    "lapse_results.csv"
export_query \
    "SELECT svr.*, s.study_name, s.study_start_date, s.study_end_date FROM study_validation_result svr JOIN experience_study s USING (study_id) ORDER BY check_name" \
    "validation_results.csv"

echo "Exported dashboard data to $output_dir"
