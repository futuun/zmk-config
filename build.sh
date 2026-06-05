#!/usr/bin/env bash
# Build all firmware targets locally and collect the .uf2 files into ./firmware/
#
# Requires: west (uv tool), ninja (uv tool), Zephyr SDK (~/zephyr-sdk-*)
# Workspace must be initialized first: west init -l config && west update
set -euo pipefail

cd "$(dirname "$0")"

# Zephyr 4.1 board target (was nice_nano_v2): nice_nano rev 2.0.0 is the
# default revision, nrf52840 the only SoC, zmk the required variant.
BOARD=nice_nano//zmk
OUT=firmware

# Shields to build (see build.yaml — keep in sync)
TARGETS=(
    kyria_rev3_d_left
    kyria_rev3_d_right
    settings_reset
)

mkdir -p "$OUT"

# Always build pristine: incremental builds (-p auto) can keep stale Kconfig
# state across devicetree changes (e.g. a sensor swap once silently reverted
# EC11_TRIGGER_OWN_THREAD to TRIGGER_NONE -> dead encoder).
for shield in "${TARGETS[@]}"; do
    echo "==> Building $shield"
    west build -p -s zmk/app -d "build/$shield" -b "$BOARD" -- \
        -DSHIELD="$shield" -DZMK_CONFIG="$PWD/config"
    cp "build/$shield/zephyr/zmk.uf2" "$OUT/$shield.uf2"
done

echo
echo "Firmware collected in $OUT/:"
ls -lh "$OUT"/*.uf2
