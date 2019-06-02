#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2016-2019 per the LGPL3 (the Third Lesser GNU Public License)
set -e ## Fail the whole script if any command within it fails.

## Get system info and declare variables
## =====================================================================

## Get the disk
## ---------------------------------------------------------------------
while [[ true ]]; do
	if [[ ! $1 ]]; then
		echo ':: Path to disk: '
		read DISK
	else DISK="$1"
	fi
	[[ -e "$DISK" ]] && break
	echo ':: Invalid disk.' >&2
done
echo

## System information
## ---------------------------------------------------------------------
echo ':: Gathering information...'
NPROC="$(nproc)"
SSD="$(cat /sys/block/$(echo $DISK | sed 's/\/dev\///')/queue/rotational)"
BOOTSIZE="500M" ## 500MB/477MiB is the recommended size for the EFI partition when used as /boot (https://www.freedesktop.org/wiki/Specifications/BootLoaderSpec)
MEMSIZE="$(free -b | grep 'Mem:' | sed 's/Mem:\s*//' | sed 's/\s.*//' )"
PAGESIZE="$(getconf PAGESIZE)"
BLOCKSIZE="$(($PAGESIZE*256))" ## 1M with a 4k pagesize.  Idk if this should be dependent on pagesize.
[[ ! -f "${DISK}1" ]] && PART='p'

## Formatting settings
## ---------------------------------------------------------------------
MKFS_BTRFS_OPTS=" --force --data single --metadata single --nodesize $PAGESIZE --sectorsize $PAGESIZE --features extref,skinny-metadata,no-holes "
MKFS_VFAT_OPTS=" -F 32 -b 6 -f 1 -h 6 -r 512 -R 12 -s 1 -S $PAGESIZE "
## SSD tweaks
if [[ SSD -gt 0 ]]; then
    MOUNT_BTRFS_OPTS="${MOUNT_BTRFS_OPTS},noautodefrag,discard,ssd_spread"
else
    MOUNT_BTRFS_OPTS="${MOUNT_BTRFS_OPTS},autodefrag,nodiscard,nossd"
fi

## Mount options
## ---------------------------------------------------------------------
MOUNTPOINT='/mnt'
MOUNT_ANY_OPTS='defaults,async,auto,iversion,relatime,strictatime,lazytime,rw' #mand## Mount options
MOUNT_BTRFS_OPTS="acl,noinode_cache,space_cache=v2,barrier,noflushoncommit,treelog,usebackuproot,datacow,datasum,compress=zstd,fatal_errors=bug,noenospc_debug,thread_pool=$NPROC,max_inline=$(echo $PAGESIZE*0.95 | bc | sed 's/\..*//')" #logreplay
MOUNT_VFAT_OPTS='check=relaxed,errors=remount-ro,tz=UTC,rodir,sys_immutable,flush' #iocharset=utf8
echo

## Mount system
## =====================================================================

## Unmount disk
## ---------------------------------------------------------------------
echo ':: Making sure disk is not mounted...'
set +e ## It's okay if this section fails
swapoff "$MOUNTPOINT/.btrfs/swapfile"
for EACH in "$DISK"*; do
	umount "$EACH"
done
set -e ## Back to failing the script like before
echo

## Mount system
## ---------------------------------------------------------------------
## ZFS exposes its internal structure with a .zfs directory;  I am doing the same thing here for btrfs.
echo ':: Mounting volumes...'
mount -o "$MOUNT_ANY_OPTS,$MOUNT_BTRFS_OPTS,subvol=/@arch" "${DISK}${PART}2" "$MOUNTPOINT"
mkdir -p "$MOUNTPOINT/.btrfs" \
         "$MOUNTPOINT/boot"   \
         "$MOUNTPOINT/home"   \
         "$MOUNTPOINT/srv"
mount -o "$MOUNT_ANY_OPTS,$MOUNT_BTRFS_OPTS,subvol=/"      "${DISK}${PART}2" "$MOUNTPOINT/.btrfs"
swapon   "$MOUNTPOINT/.btrfs/swapfile"
mount -o "$MOUNT_ANY_OPTS,$MOUNT_VFAT_OPTS"                "${DISK}${PART}1" "$MOUNTPOINT/boot"
mount -o "$MOUNT_ANY_OPTS,$MOUNT_BTRFS_OPTS,subvol=/@home" "${DISK}${PART}2" "$MOUNTPOINT/home"
mount -o "$MOUNT_ANY_OPTS,$MOUNT_BTRFS_OPTS,subvol=/@srv"  "${DISK}${PART}2" "$MOUNTPOINT/srv"
sleep 1
echo

## Cleanup
## ---------------------------------------------------------------------
echo ':: Done.'
exit 0
