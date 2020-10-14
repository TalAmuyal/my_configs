#!/bin/bash

set -euo pipefail

[ -z "$1" ] && echo "Missing check operation" && exit 1
CHECK="$1"
shift

[ -z "$1" ] && echo "Missing fix operation" && exit 1
FIX="$1"
shift

[ -z "$1" ] && echo "Missing fix name" && exit 1
FIX_NAME="$1"
shift

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

for item in "$@"; do
	echo -n " - "
	bash "$SCRIPT_DIR/fix.sh" "$CHECK $item" "$FIX $item" "$item" "$FIX_NAME"
done
