#!/bin/bash

function bizcal
{
    declare root_dir
    root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE}")/../.." && pwd)"

    ruby -I "${root_dir}/src/main" -r main -e main -- "$@"
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

