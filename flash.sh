#!/usr/bin/env bash
# Flash a .uf2 from ./firmware/ onto a nice!nano in bootloader mode.
#
# Avoids Finder's spurious "error code -36": the bootloader reboots the
# instant the last UF2 block lands, while macOS is still writing metadata
# (._* AppleDouble files, .DS_Store). We copy with cp -X (no xattrs) and
# treat the volume disappearing as the real success signal.
set -euo pipefail

cd "$(dirname "$0")"

VOLUME=/Volumes/NICENANO

case "${1-}" in
    left)  UF2=firmware/kyria_rev3_d_left.uf2 ;;
    right) UF2=firmware/kyria_rev3_d_right.uf2 ;;
    reset) UF2=firmware/settings_reset.uf2 ;;
    *)
        echo "usage: $0 left|right|reset" >&2
        exit 1
        ;;
esac

[[ -f $UF2 ]] || { echo "$UF2 not found -- run ./build.sh first" >&2; exit 1; }

if [[ ! -d $VOLUME ]]; then
    echo "Waiting for $VOLUME -- double-tap reset on the nice!nano..."
    until [[ -d $VOLUME ]]; do sleep 0.5; done
fi

echo "==> Flashing $UF2"
# The device reboots mid-copy once the firmware is fully received, so cp's
# final flush may fail with an I/O error -- expected, not a failure.
cp -X "$UF2" "$VOLUME/" 2>/dev/null || true

# Volume gone = bootloader accepted the image and rebooted.
for _ in {1..20}; do
    [[ -d $VOLUME ]] || { echo "Done -- device rebooted."; exit 0; }
    sleep 0.5
done

echo "$VOLUME is still mounted -- flash may not have completed." >&2
exit 1
