#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2016-2021 the LGPL3 (the Third Lesser GNU Public License)

## Get system info and declare variables
## #####################################################################

## Get the disks
## =====================================================================
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
declare -a DISK_TYPES=()
declare -i I=0
while [[ $I -lt $DISK_COUNT ]]; do
	DISK_TYPES[$I]=$(cat /sys/block/$(echo "${DISKS[$I]}" | sed 's/\/dev\///')/queue/rotational)
	let '++I'
done
unset I

## Unset unneeded variables
## ---------------------------------------------------------------------
unset SMALLEST_DISK_SIZE MEMSIZE SWAPSIZE

## Formatting settings
## ---------------------------------------------------------------------
MKFS_BTRFS_OPTS=" --force --data single --metadata single --nodesize $PAGESIZE --sectorsize $PAGESIZE --features extref,skinny-metadata,no-holes "
MKFS_VFAT_OPTS=" -F 32 -b 6 -f 1 -h 6 -R 12 -s 1 -S $PAGESIZE " # -r 512

## Mount options
## ---------------------------------------------------------------------
MOUNTPOINT='/media/format-drives-test'
MOUNT_ANY_OPTS='defaults,rw,async,iversion,nodiratime,relatime,strictatime,lazytime,auto' #mand
MOUNT_VFAT_OPTS='check=relaxed,errors=remount-ro,tz=UTC,rodir,sys_immutable,flush' #iocharset=utf8
MOUNT_BTRFS_OPTS="acl,noinode_cache,space_cache=v2,barrier,noflushoncommit,treelog,usebackuproot,datacow,datasum,compress=zstd,fatal_errors=bug,noenospc_debug,thread_pool=$NPROC,max_inline=$(echo $PAGESIZE*0.95 | bc | sed 's/\..*//')" #logreplay

MOUNT_BTRFS_OPTS_SSD="${MOUNT_BTRFS_OPTS},noautodefrag,discard,ssd_spread"
MOUNT_BTRFS_OPTS_HDD="${MOUNT_BTRFS_OPTS},autodefrag,nodiscard,nossd"
unset MOUNT_BTRFS_OPTS

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
## Reformat the disks
## =====================================================================
read -p ':: Format the disks? (y/N) ' INPUT
if [[ "$INPUT" = 'y' || "$INPUT" = 'Y' ]]; then

	## Figure out the partition prefix
	## ---------------------------------------------------------------------
	declare -i I=0
	for DISK in "${DISKS[@]}"; do
		[[ ! -e "${DISK}1" ]] && PART='p'
		[[ ! -e "${DISK}${PART}1" ]] && echo "Couldn't find partition!" >&2 && exit 1

		## Format partitions
		## ---------------------------------------------------------------------
		echo "Formatting disk '${DISK}'..."
		mkfs.vfat  $MKFS_VFAT_OPTS   -n     'BOOT' "${DISK}${PART}1" 1>/dev/null
		mkfs.btrfs $MKFS_BTRFS_OPTS --label 'ROOT' "${DISK}${PART}2" 1>/dev/null
		mkswap -p "$PAGESIZE"        -L     'SWAP' "${DISK}${PART}3" 1>/dev/null
		let '++I'
	done
	unset MKFS_VFAT_OPTS MKFS_BTRFS_OPTS
	sleep 1
fi
exit

## Prepare for Linux
## =====================================================================

## Figure out whether we're using an SSD
## ---------------------------------------------------------------------
# if [[ "${DISK_TYPES[$I]}" = 0 ]]; then
# 	MOUNT_BTRFS_OPTS="$MOUNT_BTRFS_OPTS_SSD"
# else
# 	MOUNT_BTRFS_OPTS="$MOUNT_BTRFS_OPTS_HDD"
# fi

## First mounts (sanity check -- remember `set -e`?)
## ---------------------------------------------------------------------
echo ':: Mounting partitions...'
mkdir -p "$MOUNTPOINT"
## BOOT (only temporarily mounted)
mount -o "$MOUNT_ANY_OPTS,$MOUNT_VFAT_OPTS"  "${DISK}${PART}1" "$MOUNTPOINT"
umount   "$MOUNTPOINT"
sleep 1
## ROOT (stays mounted)
mount -o "$MOUNT_ANY_OPTS,$MOUNT_BTRFS_OPTS" "${DISK}${PART}2" "$MOUNTPOINT"
sleep 1
echo

## Create swapfile
## ---------------------------------------------------------------------
## Using a swapfile instead of a swap partition makes it a lot easier to resize in the future.
## Placing the swapfile at the root of the btrfs tree and outside of a subvol also makes it very portable and excludes it from snapshots.
## Linux v5+ required!
## Root-level swapfiles are usually called "swapfile" in Linux distros, and we keep that convention here.
## Creating the swapfile before anything else should give it a privileged position in spinning hard disks if they put their fastest sectors at the start of the disk.
read -p ':: Create swapfile? (y/N) ' INPUT
echo
if [[ "$INPUT" = 'y' || "$INPUT" = 'Y' ]]; then
	echo ':: Creating swapfile...'
	truncate -s '0' "$MOUNTPOINT/swapfile" ## We have to create a 0-length file so we can use chattr
	chattr   +C     "$MOUNTPOINT/swapfile" ## We have to disable copy-on-write
	chattr   -c     "$MOUNTPOINT/swapfile" ## We have to make sure compression isn't enabled for it
	chmod     '600' "$MOUNTPOINT/swapfile" ## The swapfile should NOT be world-readable!
	fallocate -l "$MEMSIZE" "$MOUNTPOINT/swapfile" #NOTE:  May not work on all systems
	#dd if='/dev/zero' of="$MOUNTPOINT/swapfile" bs="$BLOCKSIZE" count="$(($MEMSIZE/$BLOCKSIZE))" status='progress' #TODO:  This may create a file that is a little smaller than $MEMSIZE, due to integer truncation.
	mkswap -p "$PAGESIZE" -L 'SWAP' "$MOUNTPOINT/swapfile"
	swapon "$MOUNTPOINT/swapfile"
	sleep 1
	echo
fi

## Create subvolumes
## ---------------------------------------------------------------------
## The idea with subvolumes is principally to ensure that
## (1) as little information is snapshotted as possible, and
## (2) different snapshots of different subvols should be able to work together.
## Also, there's a (3), which is that I'm hesitant to use subsubvolumes, because since they're excluded from their parent subvol's snapshots, I'm not sure whether they would still exist if I were to replace their parent subvol with a snapshot.  I'd rather use a .subvolignore list or something.
## Additionally, snapshots should be independent of any subvols, so that production subvols can easily be wholesale replaced by their snapshots.
## In order to meet requirement #1, child subvols should be created for temporary data.
## In order to meet requirement #2, directories like /etc and / should not be on different subvols.
## Making /home into an independent subvol meets both requirements.
## Also, I'm naming system root subvols after their distros, since that allows me to dual-boot from within the same partition.
read -p ':: Create subvolumes? (y/N) ' INPUT
echo
if [[ "$INPUT" = 'y' || "$INPUT" = 'Y' ]]; then
	echo ':: Creating subvolumes...'
	mkdir -p "$MOUNTPOINT/snapshots"       \
	         "$MOUNTPOINT/snapshots/@arch" \
	         "$MOUNTPOINT/snapshots/@home" \
	         "$MOUNTPOINT/snapshots/@srv"
	btrfs subvolume create      "$MOUNTPOINT/@arch"
	btrfs subvolume create      "$MOUNTPOINT/@home"
	btrfs subvolume create      "$MOUNTPOINT/@srv"
	btrfs subvolume set-default "$MOUNTPOINT/@arch"
	sleep 1
	echo
fi

## Unmount everything
## ---------------------------------------------------------------------
echo ':: Unmounting partitions...'
set +e ## It's okay if this section fails
swapoff "$MOUNTPOINT/swapfile"
umount  "$MOUNTPOINT"
sleep 1
set -e ## Back to failing the script like before
echo

## Cleanup
## ---------------------------------------------------------------------
echo ':: Done.'
exit 0
