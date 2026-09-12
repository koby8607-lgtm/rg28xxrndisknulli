#!/bin/sh
set -eu

PATCH="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/0001-rg28xx-backport-android-rndis-cdc-quirk.patch"

if [ ! -f drivers/net/usb/cdc_ether.c ]; then
    echo "Run this from the Linux kernel source tree."
    exit 1
fi

echo "[*] Checking patch..."
patch --dry-run -p1 < "$PATCH"

echo "[*] Applying patch..."
patch -p1 < "$PATCH"

echo "[*] Verifying..."
grep -n "android_rndis_quirk" drivers/net/usb/cdc_ether.c
grep -n "hard-wiring for RNDIS" drivers/net/usb/cdc_ether.c

echo "[+] Patch applied."
