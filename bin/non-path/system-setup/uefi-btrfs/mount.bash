#!/usr/bin/env bash

## Get disk
if [[ ! $1 ]]; then
	echo 'Disk: '
	read DISK
else DISK="$1"
fi
[[ ! -e "$DISK" ]] && echo 'Invalid disk.' && exit 1

## Get system stats
echo
echo 'Gathering statistics...'
NPROC="$(nproc)"

## Declare variables
MOUNT_ANY_OPTS='defaults,async,auto,iversion,mand,relatime,strictatime,lazytime,rw'
MOUNT_BTRFS_OPTS="autodefrag,compress=lzo,flushoncommit,acl,barrier,datacow,datasum,treelog,recovery,space_cache,thread_pool=$NPROC"
MOUNT_VFAT_OPTS='check=relaxed,errors=remount-ro,iocharset=utf8,tz=UTC,rodir,sys_immutable,flush'

## Mount
echo
echo 'Mounting partitions...'
MOUNTPOINT='/mnt'
swapon "${DISK}2"
mkdir  "$MOUNTPOINT"
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}3" "$MOUNTPOINT"
mkdir  "$MOUNTPOINT"'/boot'
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_VFAT_OPTS"  "${DISK}1" "$MOUNTPOINT"'/boot'
mkdir  "$MOUNTPOINT"'/home'
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}4" "$MOUNTPOINT"'/home'

## Cleanup
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
