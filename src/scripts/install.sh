#!/usr/bin/bash

set -eu -o posix -o pipefail

declare ROOT_DIR
ROOT_DIR="$(cd -- "$(dirname "$0")/../.." && pwd)"
declare -gr ROOT_DIR

declare BASHRC_FILE_PATH="${ROOT_DIR}/src/bashrc/bizcal.bashrc"

if ! grep -E "^source '${BASHRC_FILE_PATH}'$" ~/.bashrc > /dev/null; then
    echo "source '${BASHRC_FILE_PATH}'" >> ~/.bashrc
fi

