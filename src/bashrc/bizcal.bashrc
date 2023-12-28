#!/bin/bash

function bizcal
{
    declare root_dir
    root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

    ruby -I "${root_dir}/src/main" -r main -e main -- "$@"
}

function _bizcal.bash_complete
{
    declare -r word="${COMP_WORDS[${COMP_CWORD}]}"

    if [[ ${COMP_CWORD} == 1 ]]; then
        COMPREPLY=($(compgen -W 'help updatedb list table remaining-days' -- "${word}"))
    fi
}

complete -F _bizcal.bash_complete bizcal

