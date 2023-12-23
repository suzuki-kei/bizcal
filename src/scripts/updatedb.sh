#!/bin/bash

set -eu -o pipefail

# コマンド置換したときに errexit の値を継承する.
shopt -s inherit_errexit

declare ROOT_DIR
ROOT_DIR="$(cd -- "$(dirname -- "$0")/../.." && pwd)"
declare -gr ROOT_DIR="${ROOT_DIR}"

declare -gr DATA_DIR="${ROOT_DIR}/data"
declare -gr COMPANY_HOLIAYS_TSV_FILE_PATH="${DATA_DIR}/company-holidays.tsv"
declare -gr JAPANESE_HOLIAYS_TSV_FILE_PATH="${DATA_DIR}/japanese-holidays.tsv"

function main
{
    prepare_company_holidays_tsv_file
    prepare_japanese_holidays_tsv_file
}

function prepare_company_holidays_tsv_file
{
    mkdir -p "$(dirname -- "${COMPANY_HOLIAYS_TSV_FILE_PATH}")"

    declare -r year_from=1955
    declare -r year_to=$(date --date '1 year' '+%Y')

    for year in $(seq ${year_from} ${year_to})
    do
        echo -e "${year}-01-01\t会社休業日"
        echo -e "${year}-01-02\t会社休業日"
        echo -e "${year}-01-03\t会社休業日"
        echo -e "${year}-12-29\t会社休業日"
        echo -e "${year}-12-30\t会社休業日"
        echo -e "${year}-12-31\t会社休業日"
    done > "${COMPANY_HOLIAYS_TSV_FILE_PATH}"
}

function prepare_japanese_holidays_tsv_file
{
    mkdir -p "$(dirname -- "${JAPANESE_HOLIAYS_TSV_FILE_PATH}")"

    curl -sS 'https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv' \
        | iconv --from-code=Shift_JIS --to-code=UTF-8 \
        | awk -F '[/,]' '{printf "%04d-%02d-%02d\t%s\n", $1, $2, $3, $4}' \
        | tail -n +2 \
        > "${JAPANESE_HOLIAYS_TSV_FILE_PATH}"
}

main

