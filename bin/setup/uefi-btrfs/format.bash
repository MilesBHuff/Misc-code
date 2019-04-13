#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2016-2019 per the LGPL3 (the Third Lesser GNU Public License)

## Get disk
## ---------------------------------------------------------------------
while [[ true ]]; do
	if [[ ! $1 ]]; then
		echo 'Disk: '
		read DISK
	else DISK="$1"
	fi
	[[ -e "$DISK" ]] && break
	echo ':: Invalid disk.'
done

## Get system info
## ---------------------------------------------------------------------
echo
echo ':: Gathering information...'
make
PAGESIZE="$(./getPageSize)"
MEMSIZE='32G' ## Replace with how much RAM your computer has
NPROC="$(nproc)"
SSD="$(cat /sys/block/$(echo $DISK | sed 's/\/dev\///gmu')/queue/rotational)"
make clean

## Declare variables
## ---------------------------------------------------------------------
## FS creation
MKFS_BTRFS_OPTS=" --force --data single --metadata single --nodesize $PAGESIZE --sectorsize $PAGESIZE --features extref,skinny-metadata,no-holes " ## https://btrfs.wiki.kernel.org/index.php/Manpage/mkfs.btrfs
MKFS_VFAT_OPTS=" -b 6 -f 1 -h 6 -r 224 -R 12 -s 1 -S $PAGESIZE "
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

## Create partition table
## ---------------------------------------------------------------------
gdisk "$DISK" < "
q
" ## TODO

## Partition disk
## ---------------------------------------------------------------------
echo
echo ':: Partitioning disk...'
gdisk "$DISK" < "
o
Y
n
1

+1G
ef02
n
2

+$MEMSIZE
8200
n
3

+48G
8304
n
4


8302
w
Y
"
sleep 1
echo
echo ':: Refreshing devices...'
partprobe

## Format partitions
## ---------------------------------------------------------------------
sleep 1
echo
echo ':: Formatting partitions...'
mkfs.vfat  $MKFS_VFAT_OPTS   -n     'BOOT' "${DISK}1"
mkswap --pagesize $PAGESIZE --label 'SWAP' "${DISK}2"
mkfs.btrfs $MKFS_BTRFS_OPTS --label 'ROOT' "${DISK}3"
mkfs.btrfs $MKFS_BTRFS_OPTS --label 'HOME' "${DISK}4"

## Mount
## ---------------------------------------------------------------------
sleep 1
echo
echo ':: Mounting partitions...'
MOUNTPOINT='/media/format-drives-test'
swapon "${DISK}2"
mkdir  "$MOUNTPOINT"
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}3" "$MOUNTPOINT"
mkdir  "$MOUNTPOINT"'/boot'
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_VFAT_OPTS"  "${DISK}1" "$MOUNTPOINT"'/boot'
mkdir  "$MOUNTPOINT"'/home'
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}4" "$MOUNTPOINT"'/home'

## Rest
## ---------------------------------------------------------------------
sleep 1
echo
lsblk
echo
echo ':: Giving partitions time to adjust...'
sleep 10

## Unmount
## ---------------------------------------------------------------------
sleep 1
echo
echo ':: Unmounting partitions...'
umount  "${DISK}4"
rmdir   "$MOUNTPOINT"'/home'
umount  "${DISK}1"
rmdir   "$MOUNTPOINT"'/boot'
umount  "${DISK}3"
rmdir   "$MOUNTPOINT"
swapoff "${DISK}2"

## Cleanup
## ---------------------------------------------------------------------
sleep 1
echo
unset DISK            \
      MKFS_BTRFS_OPTS \
      MKFS_VFAT_OPTS  \
      MOUNT_ANY_OPTS  \
      MOUNT_BTRFS_OPTS\
      MOUNT_VFAT_OPTS \
      MOUNTPOINT      \
      NPROC
echo 'Done.'
exit 0
