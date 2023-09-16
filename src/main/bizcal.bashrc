#!/bin/bash

declare -r ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE}")/../.." && pwd)"

function bizcal
{
    case "$1" in
        help | -h | --help)
            echo 'Not Implemented.'
            ;;
        updatedb)
            bash "${ROOT_DIR}/src/scripts/setup.sh"
            ;;
        list | table | remaining-days)
            ruby -I "${ROOT_DIR}/src/main" -r main -e main -- "$@"
            ;;
        '' | -*)
            ruby -I "${ROOT_DIR}/src/main" -r main -e main -- table "$@"
            ;;
        *)
            echo "Invalid arguments: [$@]" >&2
            return 1
            ;;
    esac
}

function _bizcal.bash_complete
{
    declare -r word="${COMP_WORDS[${COMP_CWORD}]}"

    case "${COMP_WORDS[1]}" in
        help | updatedb | list | table | remaining-days)
            ;;
        *)
            COMPREPLY=($(compgen -W 'help updatedb list table remaining-days' -- "${word}"))
            ;;
    esac
}

complete -F _bizcal.bash_complete bizcal

