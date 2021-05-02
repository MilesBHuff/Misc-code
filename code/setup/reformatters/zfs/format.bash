#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2016-2021 the LGPL3 (the Third Lesser GNU Public License)

## Get system info and declare variables
## #####################################################################

## Get the disks
## =====================================================================
echo ':: Checking disks...'
declare -a DISKS=("$@")
declare -i I=0
while [[ true ]]; do
	if [[ $I -ge 2 ]]; then
		read -p 'Add more disks? (y/N) ' ANSWER
		[[ "$ANSWER" != 'y' && "$ANSWER" != 'Y' ]] && break;
	fi

	while [[ true ]]; do
		if [[ -z "${DISKS[$I]}" ]]; then
			read -p "Path to disk #$I: " DISKS[$I]
		fi

		if [[ -e "${DISKS[$I]}" ]]; then
			let '++I'
			break
		else
			echo "Invalid disk: '${DISKS[$I]}'." >&2
			DISKS[$I]=
		fi
	done
done
declare -i DISK_COUNT=$I
unset I

## System information
## =====================================================================
set -e ## Fail the whole script if any command within it fails.
echo ':: Gathering information...'

## Basic stuff
## ---------------------------------------------------------------------
declare -i     NPROC=$(nproc)
declare -i  PAGESIZE=$(getconf PAGESIZE)
declare -i BLOCKSIZE=$(($PAGESIZE*256)) ## 1M with a 4k pagesize.  Idk if this should be dependent on pagesize.
declare -i   MEMSIZE=$(free -b | grep 'Mem:' | sed -r 's/^Mem:\s*([0-9]+).*$/\1/')

## RAID1s have to be based on the size of the smallest disk in the array.
## ---------------------------------------------------------------------
declare -i SMALLEST_DISK_SIZE=0
for DISK in ${DISKS[@]}; do
	# declare -i SIZE=$(fdisk -l /dev/nvme1n1 | sed -r 's/^Disk .*? (\d+) bytes, [\s\S]*$/\1/')
	declare -i SIZE=$(fdisk -l /dev/nvme1n1 | grep Disk | grep sectors | sed -r 's/^.*? ([0-9]+) bytes.*$/\1/' | xargs)
	[[ $SMALLEST_DISK_SIZE -eq 0 || $SIZE -lt $SMALLEST_DISK_SIZE ]] && SMALLEST_DISK_SIZE=$SIZE
done

## Partition sizes
## ---------------------------------------------------------------------
declare -i BOOTSIZE=$((500*1024*1024)) ## 500MB/477MiB is the recommended size for the EFI partition when used as /boot (https://www.freedesktop.org/wiki/Specifications/BootLoaderSpec)
declare -i SWAPSIZE=$(($MEMSIZE/$DISK_COUNT)) ## We need at least as much swap as memory if we want to hibernate.
declare -i ROOTSIZE=$(($SMALLEST_DISK_SIZE-$SWAPSIZE-$BOOTSIZE))

## Figure out which drives are SSDs and which are HDDS, so we can use the right mount options.
## ---------------------------------------------------------------------
declare -a DISK_TYPES
declare -i I=0
while [[ $I -lt $DISK_COUNT ]]; do
	DISK_TYPES[$I]=$(cat /sys/block/$(echo "${DISKS[$I]}" | sed 's/\/dev\///')/queue/rotational)
	[[ "${DISK_TYPES[$I]}" != "${DISK_TYPES[$(($I-1))]}" ]] && echo 'I refuse to make a RAID1 of SSDs and HDDs mixed together.' && exit 1
	let '++I'
done
unset I
[[ ${DISKTYPES[0]} -eq 0 ]] && SSD=1 || SSD=0
unset DISK_TYPES

## Unset unneeded variables
## ---------------------------------------------------------------------
unset SMALLEST_DISK_SIZE MEMSIZE SWAPSIZE

## Formatting settings
## ---------------------------------------------------------------------
MKFS_VFAT_OPTS=" -F 32 -b 6 -f 1 -h 6 -R 12 -s 1 -S $PAGESIZE " # -r 512
MKFS_ZFS_OPTS=""

## Mount options
## ---------------------------------------------------------------------
MOUNTPOINT='/media/format-drives-test'
MOUNT_ANY_OPTS='defaults,rw,async,iversion,nodiratime,relatime,strictatime,lazytime,auto' #mand
MOUNT_VFAT_OPTS='check=relaxed,errors=remount-ro,tz=UTC,rodir,sys_immutable,flush' #iocharset=utf8
MOUNT_ZFS_OPTS=''

## Names & labels
## ---------------------------------------------------------------------
RPOOL_NAME='ROOT'
  ESP_NAME='BOOT'
 SWAP_NAME='SWAP'

## Prepare system
## #####################################################################

## Unmount the disks
## =====================================================================
echo ':: Making sure the disks are not mounted...'
set +e ## It's okay if this section fails
for DISK in ${DISKS[@]}; do
	for EACH in "$DISK"*; do
		umount  "$EACH" 2>/dev/null
		swapoff "$EACH" 2>/dev/null
	done
done
set -e ## Back to failing the script like before

## Repartition the disks
## =====================================================================
read -p ':: Partition the disks? (y/N) ' INPUT
if [[ "$INPUT" = 'y' || "$INPUT" = 'Y' ]]; then

	## Partition disks
	## ---------------------------------------------------------------------
	for DISK in "${DISKS[@]}"; do
		echo "Partitioning '${DISK}'..."
		(	echo 'o'          ## Create a new GPT partition table
			echo 'Y'          ## Confirm

			echo 'n'          ## Create a new partition
			echo ''           ## Use the default partition number (1)
			echo ''           ## Choose the default start location (2048)
			echo "+$(($BOOTSIZE/1024/1024))M" ## Make it as large as $BOOTSIZE
			echo 'ef00'       ## Declare it to be a UEFI partition
			echo 'c'          ## Change a partition's name
			echo 'BOOT'       ## The name of the partition

			echo 'n'          ## Create a new partition
			echo '2'          ## Choose the partition number
			echo ''           ## Choose the default start location (where the last partition ended)
			echo "+$(($ROOTSIZE/1024/1024/1024))G" ## Make it as large as $ROOTSIZE
			echo '8300'       ## Declare it to be a Linux x86-64 root partition
			echo 'c'          ## Change a partition's name
			echo '2'          ## The partition whose name to change
			echo 'ROOT'       ## The name of the partition

			echo 'n'          ## Create a new partition
			echo '3'          ## Choose the partition number
			echo ''           ## Choose the default start location (where the last partition ended)
			echo ''           ## Choose the default end location   (the end of the disk)
			echo '8200'       ## Declare it to be a Linux x86-64 swap partition
			echo 'c'          ## Change a partition's name
			echo '3'          ## The partition whose name to change
			echo 'SWAP'       ## The name of the partition

			echo 'w'          ## Write the changes to disk
			echo 'Y'          ## Confirm
		) | gdisk "$DISK" 1>/dev/null
	done
	sleep 1

	## Refresh disks
	## ---------------------------------------------------------------------
	echo 'Refreshing devices...'
	set +e ## It's okay if this section fails
	partprobe
	sleep 1
	set -e ## Back to failing the script like before

fi
## Figure out the partition labels for the drives
## ---------------------------------------------------------------------
declare -a PART_LABELS
declare -i I=0
while [[ $I -lt $DISK_COUNT ]]; do
	PART_LABELS[$I]=''
	[[ ! -e "${DISKS[$I]}1" ]] && PART_LABELS[$I]='p'
	[[ ! -e "${DISKS[$I]}${PART_LABELS[$I]}1" ]] && echo "Couldn't find partition!" >&2 && exit 1
	let '++I'
done
unset I

## Reformat the disks
## =====================================================================
read -p ':: Format the disks? (y/N) ' INPUT
if [[ "$INPUT" = 'y' || "$INPUT" = 'Y' ]]; then

	## Format partitions
	## ---------------------------------------------------------------------
	declare -i I=0
	while [[ $I -lt $DISK_COUNT ]]; do
		echo "Formatting disk '${DISK}'..."
		mkfs.vfat  $MKFS_VFAT_OPTS -n "$ESP_NAME" "${DISKS[$I]}${PART_LABELS[$I]}1" 1>/dev/null
		mkswap -p "$PAGESIZE"      -L "$SWAP_NAME" "${DISKS[$I]}${PART_LABELS[$I]}3" 1>/dev/null
		let '++I'
	done
	unset MKFS_VFAT_OPTS

	## Create zpool
	## ---------------------------------------------------------------------
	echo "Creating RAID volume..."
	declare -a POOL_PARTS
	declare -i I=0
	while [[ $I -lt $DISK_COUNT ]]; do
		POOL_PARTS[$I]=${DISKS[$I]}${PART_LABELS[$I]}2
		let '++I'
	done
	unset I
	zpool create "$RPOOL_NAME" -fm "/mnt" mirror "${POOL_PARTS[@]}"
	sleep 1
	umount "/mnt"
	sleep 1

	## Create datasets
	## ---------------------------------------------------------------------
	echo 'Creating datasets...'
	#TODO
fi

## Prepare for Linux
## =====================================================================
#TODO
read -p ':: Mount and prep? (y/N) ' INPUT
if [[ "$INPUT" = 'y' || "$INPUT" = 'Y' ]]; then

	## First mounts (sanity check -- remember `set -e`?)
	## ---------------------------------------------------------------------
	echo 'Mounting partitions...'
	mkdir -p "$MOUNTPOINT"
	## BOOT (only temporarily mounted)
	mount -o "$MOUNT_ANY_OPTS,$MOUNT_VFAT_OPTS"  "${DISK}${PART}1" "$MOUNTPOINT"
	umount   "$MOUNTPOINT"
	sleep 1
	## ROOT (stays mounted)
	mount -o "$MOUNT_ANY_OPTS,$MOUNT_BTRFS_OPTS" "${DISK}${PART}2" "$MOUNTPOINT"
	sleep 1
	echo

	## Unmount everything
	## ---------------------------------------------------------------------
	echo 'Unmounting partitions...'
	set +e ## It's okay if this section fails
	swapoff "$MOUNTPOINT/swapfile"
	umount  "$MOUNTPOINT"
	sleep 1
	set -e ## Back to failing the script like before
	echo
fi

## Cleanup
## ---------------------------------------------------------------------
echo ':: Done.'
exit 0
