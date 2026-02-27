#!/bin/bash
set -ex

cd /home/szoltysek/docker-linux/pdx206/initramfs_root
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
cd ..

BOOT_DIR="/home/szoltysek/.local/var/pmbootstrap/chroot_rootfs_sony-pdx206/boot"
KERNEL="$BOOT_DIR/vmlinuz"
DTB_PDX206="/tmp/pdx206-gpu-dsi-panel.dtb"

OUTPUT="mainline_fixed.img"

mkbootimg --kernel "$KERNEL" \
          --ramdisk "initramfs.cpio.gz" \
          --dtb "$DTB_PDX206" \
          --base 0x0 \
          --kernel_offset 0x8000 \
          --ramdisk_offset 0x01000000 \
          --tags_offset 0x100 \
          --dtb_offset 0x01f00000 \
          --pagesize 4096 \
          --header_version 2 \
          --cmdline "console=ttyMSM0,115200n8 console=tty0 earlycon=msm_geni_serial,0xa90000 root=/dev/mmcblk0p2 rw rootwait loglevel=7 ignore_loglevel" \
          --output "$OUTPUT"

echo "File created - $OUTPUT"
fastboot flash boot_a "$OUTPUT"
fastboot flash boot_b "$OUTPUT"
fastboot set_active a
fastboot reboot