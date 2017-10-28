#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)

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
make
PAGESIZE="$(./getPageSize)"
MEMSIZE='4096M'
NPROC="$(nproc)"
make clean

## Declare variables
MKFS_BTRFS_OPTS=" --force --data single --metadata single --nodesize $PAGESIZE --sectorsize $PAGESIZE --features mixed-bg,extref,skinny-metadata,no-holes "
MKFS_VFAT_OPTS=" -b 6 -f 1 -h 6 -r 224 -R 12 -s 1 -S $PAGESIZE "
MOUNT_ANY_OPTS='defaults,async,auto,iversion,mand,relatime,strictatime,lazytime,rw'
MOUNT_BTRFS_OPTS="autodefrag,compress=lzo,flushoncommit,acl,barrier,datacow,datasum,treelog,recovery,space_cache,thread_pool=$NPROC"
MOUNT_VFAT_OPTS='check=relaxed,errors=remount-ro,iocharset=utf8,tz=UTC,rodir,sys_immutable,flush'

## Partition disk
echo
echo 'Partitioning disk...'
echo "
o
Y
n
1

+1M
ef02
n
2

+$MEMSIZE
8200
n
3

+20G
8304
n
4


8302
w
Y
" | gdisk "$DISK"
sleep 1
echo
echo 'Refreshing devices...'
partprobe

## Format partitions
sleep 1
echo
echo 'Formatting partitions...'
#mkfs.vfat  $MKFS_VFAT_OPTS   -n     'BOOT' "${DISK}1"
mkswap --pagesize $PAGESIZE --label 'SWAP' "${DISK}2"
mkfs.btrfs $MKFS_BTRFS_OPTS --label 'ROOT' "${DISK}3"
mkfs.btrfs $MKFS_BTRFS_OPTS --label 'HOME' "${DISK}4"

## Mount
sleep 1
echo
echo 'Mounting partitions...'
MOUNTPOINT='/media/format-drives-test'
swapon "${DISK}2"
mkdir  "$MOUNTPOINT"
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}3" "$MOUNTPOINT"
#mkdir  "$MOUNTPOINT"'/boot'
#mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_VFAT_OPTS"  "${DISK}1" "$MOUNTPOINT"'/boot'
mkdir  "$MOUNTPOINT"'/home'
mount  -o "$MOUNT_ANY_OPTS"','"$MOUNT_BTRFS_OPTS" "${DISK}4" "$MOUNTPOINT"'/home'

## Sleep
sleep 1
echo
lsblk
echo
echo 'Giving partitions time to adjust...'
sleep 10

## Unmount
sleep 1
echo
echo 'Unmounting partitions...'
#TODO
umount  "${DISK}4"
rmdir   "$MOUNTPOINT"'/home'
#umount  "${DISK}1"
#rmdir   "$MOUNTPOINT"'/boot'
umount  "${DISK}3"
rmdir   "$MOUNTPOINT"
swapoff "${DISK}2"

## Cleanup
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
