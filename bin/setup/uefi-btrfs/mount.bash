#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)

## Get disk
## ---------------------------------------------------------------------
while [ true ]; do
	if [[ ! $1 ]]; then
		echo 'Disk: '
		read DISK
	else DISK="$1"
	fi
	[[ ! -e "$DISK" ]] && break
	echo 'Invalid disk.'
done

## Get system info
## ---------------------------------------------------------------------
echo
echo ':: Gathering information...'
make
PAGESIZE="$(./getPageSize)"
NPROC="$(nproc)"
SSD="$(cat /sys/block/$(echo $DISK | sed 's/\/dev\///gmu')/queue/rotational)"
make clean

## Declare variables
## ---------------------------------------------------------------------
## FS mounting
MOUNT_ANY_OPTS='defaults,async,auto,iversion,mand,relatime,strictatime,lazytime,rw'
MOUNT_BTRFS_OPTS="acl,noinode_cache,space_cache=v2,barrier,noflushoncommit,treelog,logreplay,usebackuproot,datacow,datasum,compress=zstd,fatal_errors=bug,noenospc_debug,thread_pool=$NPROC,max_inline=$(echo $PAGESIZE*0.95 | bc | sed 's/\..*//')" ## https://btrfs.wiki.kernel.org/index.php/Manpage/btrfs(5)#MOUNT_OPTIONS
MOUNT_VFAT_OPTS='check=relaxed,errors=remount-ro,iocharset=utf8,tz=UTC,rodir,sys_immutable,flush'
## SSD tweaks
if [[ SSD -gt 0 ]]; then
    MOUNT_BTRFS_OPTS="${MOUNT_BTRFS_OPTS},noautodefrag,discard,ssd_spread"
else
    MOUNT_BTRFS_OPTS="${MOUNT_BTRFS_OPTS},autodefrag,nodiscard,nossd"
fi

## Mount
## ---------------------------------------------------------------------
echo
echo ':: Mounting partitions...'
MOUNTPOINT='/mnt'
swapon "${DISK}2"
mkdir  "$MOUNTPOINT"
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}3" "$MOUNTPOINT"
mkdir  "$MOUNTPOINT"'/boot'
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_VFAT_OPTS"  "${DISK}1" "$MOUNTPOINT"'/boot'
mkdir  "$MOUNTPOINT"'/home'
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}4" "$MOUNTPOINT"'/home'

## Cleanup
## ---------------------------------------------------------------------
sleep 1
echo
unset DISK            \
      MOUNT_ANY_OPTS  \
      MOUNT_BTRFS_OPTS\
      MOUNT_VFAT_OPTS \
      MOUNTPOINT      \
      NPROC
echo 'Done.'
exit 0
