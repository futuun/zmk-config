#!/usr/bin/env bash
# Build all firmware targets locally and collect the .uf2 files into ./firmware/
#
# Requires: west (uv tool), ninja (uv tool), Zephyr SDK (~/zephyr-sdk-*)
# Workspace must be initialized first: west init -l config && west update
set -euo pipefail

cd "$(dirname "$0")"

BOARD=nice_nano//zmk
OUT=firmware

TARGETS=(
    kyria_rev3_d_left
    kyria_rev3_d_right
    settings_reset
)

mkdir -p "$OUT"

# Always build clean, incremental builds can keep stale Kconfig state
for shield in "${TARGETS[@]}"; do
    echo "==> Building $shield"
    west build -p -s zmk/app -d "build/$shield" -b "$BOARD" -- \
        -DSHIELD="$shield" -DZMK_CONFIG="$PWD/config"
    cp "build/$shield/zephyr/zmk.uf2" "$OUT/$shield.uf2"
done

echo
echo "Firmware collected in $OUT/:"
ls -lh "$OUT"/*.uf2
