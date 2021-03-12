#!/usr/bin/env bash

set -e

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${__dir}/build_funcs.sh"

compile linux   386
compile linux   amd64
compile linux   arm
compile linux   arm64
compile darwin  386
compile darwin  amd64
compile windows 386   .exe
compile windows amd64 .exe
