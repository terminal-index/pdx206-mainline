#!/bin/bash
echo "Stop automounting (udisks2)"
sudo systemctl stop udisks2.service
sudo systemctl mask udisks2.service

echo "Install postmarketOS to /dev/mmcblk0"
sudo -E pmbootstrap install --sdcard=/dev/mmcblk0

echo "Unmask and start udisks2"
sudo systemctl unmask udisks2.service
sudo systemctl start udisks2.service

echo "Run custom boot.img repack for Mainline Kernel + Hybrid DTB"
./repack_mainline_fixed.sh

echo "done"
