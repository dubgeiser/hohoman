#!/usr/bin/env bash

#
# --[ rpimg.sh ]--
#
# Downloads a Raspberrypi image from `$IMG_URL`
# Writes it to an sd card `$SD_DEVICE`
# Enables SSH access
# Optionally sets Wifi credentials
#

# --[ Config ]--
IMG_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2025-05-13/2025-05-13-raspios-bookworm-arm64-lite.img.xz"
SD_DEVICE="/dev/mmcblk0"
# --[ /Config]--

set -euo pipefail

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

echo "Downloading Raspberry Pi OS image..."
wget -O rpi.img.xz "$IMG_URL"

echo "Extracting image..."
unxz rpi.img.xz

IMG_FILE=$(ls ./*.img)
echo "Image extracted: $IMG_FILE"

echo "Writing image to $SD_DEVICE (this will erase all data!)"
sudo dd if="$IMG_FILE" of="$SD_DEVICE" bs=4M conv=fsync status=progress

sync
echo "Image written to SD card."

# Assumes boot partition is the first partition of the SD card
BOOT_PART="${SD_DEVICE}p1"

MNTDIR=$(mktemp -d)
echo "Mounting boot partition $BOOT_PART to $MNTDIR"
sudo mount "$BOOT_PART" "$MNTDIR"

echo "Enabling SSH..."
sudo touch "$MNTDIR/ssh"

echo "Syncing and unmounting..."
sync
sudo umount "$MNTDIR"

echo "Done! Insert the SD card into your Raspberry Pi and power it up."
