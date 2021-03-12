#!/usr/bin/env bash

set -e

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${__dir}/build_funcs.sh"

maketar linux   386
maketar linux   amd64
maketar linux   arm
maketar linux   arm64
makezip darwin  386
makezip darwin  amd64
makezip windows 386   .exe
makezip windows amd64 .exe
makedep amd64
makedep arm64
