#!/bin/bash

set -uo pipefail
 
h=$(git rev-parse --short HEAD)

if ! git describe --tags --exact-match "$h" 2> /dev/null; then
    echo "$h"
fi

