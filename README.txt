RG28XX / KNULLI Android-RNDIS CDC workaround
================================================

Target
------
Anbernic RG28XX / Allwinner H700
KNULLI Linux 4.9.170
Phone USB ID observed: 1782:000c (Unisoc)

Problem
-------
The running KNULLI kernel has usbnet built in, while rndis_host is
missing. The previously built rndis_host.ko can be forced into the
kernel with insmod -f, but probing the phone reaches cdc_ether and
fails with:

    bad CDC descriptors

This patch is for the built-in cdc_ether path. It cannot be fixed by
replacing rndis_host.ko alone.

Patch
-----
The patch backports the Android RNDIS handling present in newer Linux:

1. If the CDC Union descriptor names interfaces that do not exist,
   RNDIS is allowed to fall through instead of being rejected.
2. RNDIS then uses USB interface 0 as control and interface 1 as data.
3. The ACM bmCapabilities rejection is limited to genuine USB
   Communication-class RNDIS interfaces.

This matches the upstream Android-RNDIS behavior documented in
Linux's cdc_ether implementation.

Apply
-----
From the Linux source tree:

    patch -p1 < 0001-rg28xx-backport-android-rndis-cdc-quirk.patch

Then verify the source:

    grep -n "android_rndis_quirk" drivers/net/usb/cdc_ether.c
    grep -n "hard-wiring for RNDIS" drivers/net/usb/cdc_ether.c

Build the kernel with the KNULLI H700 configuration.

IMPORTANT
---------
Do not use insmod -f for the final kernel/module combination.

This is a source patch, not a prebuilt kernel. It must be built against
the kernel source/config used for the RG28XX KNULLI image.

The patch deliberately does not add a device-specific USB ID. RNDIS
matching remains controlled by the existing RNDIS interface matching
logic.

Expected test
-------------
After booting the patched kernel and loading rndis_host.ko:

    modprobe rndis_host
    dmesg | grep -iE 'rndis|cdc|usbnet|1782'
    ip link

The desired result is a network interface such as usb0.

If the CDC error disappears but usb0 still does not appear, the next
failure to inspect is the RNDIS status endpoint or bulk endpoint
negotiation. That would be a later stage than the current
"bad CDC descriptors" failure.
