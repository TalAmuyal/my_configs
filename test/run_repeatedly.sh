#!/bin/zsh

setopt extendedglob && fswatch -o ^.git | xargs -n1 -I{} bash ./test/run_local.sh
