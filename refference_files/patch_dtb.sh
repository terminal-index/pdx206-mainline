#!/bin/bash
set -ex

ORIG_DTB="$1"
if [ -z "$ORIG_DTB" ]; then
    echo "Usage: $0 <path-to-sm8250-sony-xperia-edo-pdx206.dtb>"
    exit 1
fi

WORK_DIR=$(mktemp -d)
DTS_FILE="$WORK_DIR/pdx206.dts"
PATCHED_DTB="$WORK_DIR/pdx206-patched.dtb"

dtc -I dtb -O dts -o "$DTS_FILE" "$ORIG_DTB" 2>/dev/null

sed -i '/gpu@3d00000 {/,/^[[:space:]]*};/ {
    s/status = "disabled"/status = "okay"/
}' "$DTS_FILE"

sed -i '/gmu@3d6a000 {/,/^[[:space:]]*};/ {
    s/status = "disabled"/status = "okay"/
}' "$DTS_FILE"

sed -i '/display-subsystem@ae00000 {/,/^[[:space:]]*};/ {
    /display-controller@ae01000/,/};/ {
        s/status = "disabled"/status = "okay"/
    }
}' "$DTS_FILE"

sed -i '/dsi@ae94000 {/,/^[[:space:]]*};/ {
    0,/status = "disabled"/ {
        s/status = "disabled"/status = "okay"/
    }
}' "$DTS_FILE"

sed -i '/phy@ae94400 {/,/^[[:space:]]*};/ {
    s/status = "disabled"/status = "okay"/
}' "$DTS_FILE"
sed -i '/video-codec@aa00000 {/,/^[[:space:]]*};/ {
    s/status = "disabled"/status = "okay"/
}' "$DTS_FILE"

dtc -I dts -O dtb -o "$PATCHED_DTB" "$DTS_FILE" 2>/dev/null

cp "$PATCHED_DTB" "${ORIG_DTB%.dtb}-patched.dtb"

dtc -I dtb -O dts "${ORIG_DTB%.dtb}-patched.dtb" 2>/dev/null | grep -B2 'status = "okay"' | grep -E "gpu@|gmu@|display|dsi@|phy@ae94|video-codec|status"

rm -rf "$WORK_DIR"
