#!/bin/bash

set -euo pipefail

[ -z "$1" ] && echo "Missing check operation" && exit 1
CHECK="$1"
shift

[ -z "$1" ] && echo "Missing fix operation" && exit 1
FIX="$1"
shift

[ -z "$1" ] && echo "Missing item name" && exit 1
ITEM_NAME="$1"
shift

[ -z "$1" ] && echo "Missing fix name" && exit 1
FIX_NAME="$1"
shift

if $(eval "$CHECK" > /dev/null 2>&1) ; then
	if [[ "$FIX_NAME" == *e ]] ; then
		PAST_POSTFIX="d"
	else
		PAST_POSTFIX="ed"
	fi
	echo "$ITEM_NAME already ${FIX_NAME}${PAST_POSTFIX}"
	exit 0
fi

echo "$FIX"
$(eval "$FIX")

if $(eval "$CHECK" > /dev/null 2>&1) ; then
	CAPITALIZED_FIX_NAME=$(echo "$FIX_NAME" | awk '{print toupper(substr($1,1,1)) substr($1,2)}')
	echo "$CAPITALIZED_FIX_NAME $ITEM_NAME"
else
	echo "Failed to ${FIX_NAME} $ITEM_NAME using $FIX"
	exit 1
fi
