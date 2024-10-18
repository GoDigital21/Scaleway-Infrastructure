#!/bin/bash

# Automatically find the correct device (50GB) based on its size
DEVICE=$(lsblk -b -dn -o NAME,SIZE | grep -w 50000000000 | awk '{print $1}')

# If no device was found, exit the script
if [ -z "$DEVICE" ]; then
    echo "No 50GB device found"
    exit 1
fi

DEVICE="/dev/$DEVICE"

# Check if the found device is already formatted and format it if necessary
blkid --match-token TYPE=ext4 "$DEVICE" || mkfs.ext4 "$DEVICE"

# Create /data mount point if it doesn't exist
if [ -d /data ]; then
    echo "/data already exists"
else
    echo "Creating /data"
    mkdir /data
fi

# Check if the device is already mounted
if grep -qs "$DEVICE" /proc/mounts; then
    echo "$DEVICE already mounted"
else
    echo "Mounting $DEVICE"
    mount "$DEVICE" /data
fi

# Make sure that the device is mounted automatically on boot
if grep -qs "$DEVICE" /etc/fstab; then
    echo "$DEVICE already in fstab"
else
    echo "Adding $DEVICE to fstab"
    echo "$DEVICE /data ext4 defaults 0 0" >> /etc/fstab
fi

# Create /data/containers directory if it doesn't exist
if [ -d /data/containers ]; then
    echo "/data/containers already exists"
else
    echo "Creating /data/containers"
    mkdir /data/containers
fi
