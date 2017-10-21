#!/bin/sh
## Jist:  ZFS will be used as the LVM, while XFS will be used for the actual FS.  
##        This allows the speed of XFS with the awesomeness of ZFS's LVM features (there is none better), which include *compression*.  
##        Since XFS will be used for the FS, several zvol block-devices will have to be created, 
##        and since these block-devices have to have a preset size, it's easiest to have a different zpool for each.  
##        Since ZFS is only the LVM, we're going to handle it in FUSE, so that we can use other custom kernels.  

## Prevent accidental runs
# exit 0

## SKIP can be used to skip already-done sections.  The following explains what its values do:  
## n<0 = same as 0 (skip nothing)
##   0 = don't skip anything
##   1 = skip partitioning
##   2 = skip zpool-creation, as well as anything above
##   3 = skip zvol-creation, as well as anything above
##   4 = skip formatting, as well as anything above
##   5 = skip settings, as well as anything above
##   6 = skip mounting, as well as anything above
## n>6 = same as 6 (skip everything)
SKIP=0

### PARTITIONING --------------------------------------------------------------------------------------

if [ $SKIP -lt 1 ]; then
  
  ## Set up device-variables
  DEVICE0=/dev/sda
  DEVICE1=/dev/sdb
  
  echo "Cleaning disks...  "
  sgdisk -Z $DEVICE0
  sgdisk -Z $DEVICE1
  echo

  echo "Creating GPT...  "
  sgdisk -o $DEVICE0
  sgdisk -o $DEVICE1
  echo
  
  ## Uncomment if not using UEFI
  # echo "Creating bootloader partitions...  "
  # SIZE='+2M'  ## To be used for the bootloader (it's just how GPT rolls).  
  # sgdisk -a 4096 -n 4:2M:$SIZE $DEVICE0
  # sgdisk -a 4096 -n 4:2M:$SIZE $DEVICE1
  # echo
  
  echo "Creating boot partitions...  "
  SIZE='+200M'  ## (based on previous systems' usage).  To be used for /boot and CMOS backups.  
  sgdisk -a 4096 -n 1:2M:$SIZE $DEVICE0  ## If using bootloader-partition (see above), remove '2M' from this line.  
  sgdisk -a 4096 -n 1:2M:$SIZE $DEVICE1  ## If using bootloader-partition (see above), remove '2M' from this line.  
  echo
  
  echo "Creating swap partitions...  "
  SIZE='+4G'  ## To be used for swap.  Size should equal half the amount of RAM in the system (combined, this makes an amount equal to the amount of RAM), so that the system can hibernate.  
  sgdisk -a 4096 -n 2:0:$SIZE $DEVICE0
  sgdisk -a 4096 -n 2:0:$SIZE $DEVICE1
  echo
  
  echo "Creating data partitions...  "
  SIZE='-2M'  ## The entire rest of the drive, minus 2M for compatibility with some obscure programs
  sgdisk -a 4096 -n 3:0:$SIZE $DEVICE0
  sgdisk -a 4096 -n 3:0:$SIZE $DEVICE1
  echo
  
  ## Display partition-layout
  lsblk
  echo "Pause for user-evaluation.  Press any key to continue.  "
  read
fi

### ZPOOLS --------------------------------------------------------------------------------------------

if [ $SKIP -lt 2 ]; then
  
  ## Set variables
  VGOPTS='-o ashift=12 -o feature@enabled_txg=enabled -o feature@lz4_compress=enabled -o feature@embedded_data=enabled -o feature@large_blocks=enabled -o feature@hole_birth=enabled -o feature@empty_bpobj=enabled -o feature@extensible_dataset=enabled -o feature@spacemap_histogram=enabled -o feature@bookmarks=enabled -o feature@async_destroy=enabled'
  FSOPTS='-O aclinherit=noallow -O acltype=posixacl -O compression=lz4 -O primarycache=metadata -O recordsize=4096 -O redundant_metadata=most -O secondarycache=metadata -O xattr=sa'
  
  echo "Creating swap zpool...  "
  DEVICE0='/dev/sda2'
  DEVICE1='/dev/sdb2'
  ## zpool with RAID-0.  
  zpool create $VGOPTS $FSOPTS -m legacy -f 'zvg0' $DEVICE0 $DEVICE1
  echo
  
  echo "Creating data zpool...  "
  DEVICE0='/dev/sda3'
  DEVICE1='/dev/sdb3'
  ## zpool with RAID-1.  
  zpool create $VGOPTS $FSOPTS -m legacy -f 'zvg1' mirror $DEVICE0 $DEVICE1
  echo
  
  ## Display partition-layout
  zpool get size
  echo "Pause for user-evaluation.  Press any key to continue.  "
  read
fi

### ZVOLS ---------------------------------------------------------------------------------------------

if [ $SKIP -lt 3 ]; then
  
  ## Set variables
  FSOPTS='-o compression=lz4 -o primarycache=metadata -o redundant_metadata=most -o secondarycache=metadata'
  
  echo "Creating swap zvol...  "
  # ## ZFS is a dick and refuses to tell us the exact amount of free space, so we have to do a shit-tonne of calculations to approach it.  Too bad I suck at math.  Also too bad that bash doesn't support floats.  And yes, those are dozenal percents.  
  # SIZE=$(zpool list -H -o free 'zvg1' | tr -d 'G')
  # let "SIZE   = $SIZE * 10000000"
  # let "OFFSET = $SIZE * 4"
  # let "OFFSET = $OFFSET / 144"
  # let "SIZE   = $SIZE - $OFFSET"
  # let "REM    = $SIZE % 4096"
  # let "SIZE   = $SIZE - $REM"
  # echo  "size = $SIZE"
  ## But using sparse volumes frees us from the above, somewhat.  
  SIZE=$(zpool list -H -o free 'zvg0' | tr -d 'G' | tr -d '.')
  let  "SIZE = $SIZE * 10000000"
  let  "REM  = $SIZE % 4096"
  let  "SIZE = $SIZE - $REM"
  echo "size = $SIZE"
  zfs create -s -b 4096 $FSOPTS -V $SIZE 'zvg0/SWAP'
  echo
  
  ## Set variables
  FREE=$(zpool list -H -o free 'zvg1')
  
  echo "Creating root zvol...  "
  SIZE='48G'
  SIZE=$(echo $SIZE | tr -d 'G')
  let  "SIZE = $SIZE * 1000000000"
  let  "REM  = $SIZE % 4096"
  let  "SIZE = $SIZE - $REM"
  echo "size = $SIZE"
  zfs create -s -b 4096 $FSOPTS -V $SIZE 'zvg1/ROOT'
  echo
  
  ## Set variables
  ROOT=$SIZE
  
  echo "Creating persistant zvol...  "
  # ## ZFS is a dick and refuses to tell us the exact amount of free space, so we have to do a shit-tonne of calculations to approach it.  Too bad I suck at math.  Also too bad that bash doesn't support floats.  And yes, those are dozenal percents.  
  # SIZE=$(zpool list -H -o free 'zvg1' | tr -d 'G')
  # let "SIZE   = $SIZE * 1000000000"
  # let "OFFSET = $SIZE * 4"
  # let "OFFSET = $OFFSET / 144"
  # let "SIZE   = $SIZE - $OFFSET"
  # let "REM    = $SIZE % 4096"
  # let "SIZE   = $SIZE - $REM"
  # echo  "size = $SIZE"
  ## But using sparse volumes frees us from the above, somewhat.  
  SIZE=$(echo $FREE | tr -d 'G')
  let  "SIZE = $SIZE * 1000000000"
  let  "SIZE = $SIZE - $ROOT"
  let  "REM  = $SIZE % 4096"
  let  "SIZE = $SIZE - $REM"
  echo "size = $SIZE"
  zfs create -s -b 4096 $FSOPTS -V $SIZE 'zvg1/PRST'
  echo
  
  ## Display partition-layout
  #df -h
  echo "Pause for user-evaluation.  Press any key to continue.  "
  read
fi

### FORMATTING ----------------------------------------------------------------------------------------

if [ $SKIP -lt 4 ]; then

  echo "Formatting boot partitions as VFAT...  "
  DEVICE0='/dev/sda1'
  DEVICE1='/dev/sdb1'
  NAME='BOOT'
  mkfs.vfat -v -s 1 -S 4096 -n $NAME $DEVICE0  ## UEFI calls for FAT32 (ie, "-F 32"), but it runs fine on smaller FAT's
  echo
  mkfs.vfat -v -s 1 -S 4096 -n $NAME $DEVICE1  ## UEFI calls for FAT32 (ie, "-F 32"), but it runs fine on smaller FAT's
  echo
  
  echo "Formatting swap zvol as swap...  "
  DEVICE0='/dev/zvol/zvg0/SWAP'
  mkswap -p 4096 -L 'swap0' $DEVICE0
  echo
  
  echo "Formatting root zvol at XFS...  "
  DEVICE0='/dev/zvol/zvg1/ROOT'
  mkfs.xfs -s 'size=4096' -b 'size=1s' -d 'su=1b,sw=2' -i 'maxpct=0,align=1,projid32bit=1' -l 'internal=1,su=1b' -f $DEVICE0
  echo
  
  echo "Formatting persistant zvol as XFS...  "
  DEVICE0='/dev/zvol/zvg1/PRST'
  mkfs.xfs -s 'size=4096' -b 'size=1s' -d 'su=1b,sw=2' -i 'maxpct=0,align=1,projid32bit=1' -l 'internal=1,su=1b' -f $DEVICE0
  echo
  
  ## Display partition-layout
  #df -h
  echo "Pause for user-evaluation.  Press any key to continue.  "
  read
fi

### FLAGS & PROPERTIES --------------------------------------------------------------------------------

if [ $SKIP -lt 5 ]; then
  
  ## Set the bootfs
  # zpool set bootfs=ROOT zvg1
  
  ## Set partition-types
  ## Seems to fail when run from this script;  must therefore be done manually
  # echo "Setting partition-types... "
  # # sgdisk -t ef02 /dev/sda4  ## If UEFI is not used
  # # sgdisk -t ef02 /dev/sdb4  ## If UEFI is not used
  # sgdisk -t ef00 /dev/sda1  ## If UEFI is used
  # sgdisk -t ef00 /dev/sdb1  ## If UEFI is used
  # sgdisk -t 8200 /dev/sda2
  # sgdisk -t 8200 /dev/sdb2
  # # sgdisk -t 8304 /dev/sda3  ## If ROOT and PRST don't share the same real partition
  # # sgdisk -t 8304 /dev/sdb3  ## If ROOT and PRST don't share the same real partition
  # # sgdisk -t 8302 /dev/sda4  ## If PRST is its own real partition
  # # sgdisk -t 8302 /dev/sdb4  ## If PRST is its own real partition
  
  ## Display partition-layout
  #lsblk
  echo "Pause for user-evaluation.  Press any key to continue.  "
  read
fi

### MOUNTING ------------------------------------------------------------------------------------------

if [ $SKIP -lt 6 ]; then

  ## Notify the user
  echo "Attempting to mount partitions...  "
  
  ## Swapon swap
  DEVICE0='/dev/zvol/zvg0/SWAP'
  swapon -v $DEVICE0
  
  ## Mount /
  DEVICE0='/dev/zvol/zvg1/ROOT'
  mount -v --source $DEVICE0 --target '/mnt' --type 'xfs' -o 'defaults,iversion,noikeep,inode64,largeio,swalloc'
  
  ## Mount /boot
  DEVICE0='/dev/sda1'
  cd '/mnt'
  mkdir 'boot'
  mount -v --source $DEVICE0 --target '/mnt/boot' --type 'vfat' -o 'defaults,check=relaxed,tz=UTC,sys_immutable'
  
  ## Mount /boot/bak
  DEVICE0='/dev/sdb1'
  cd '/mnt/boot'
  mkdir 'bak'
  mount -v --source $DEVICE0 --target '/mnt/boot/bak' --type 'vfat' -o 'defaults,check=relaxed,tz=UTC,sys_immutable'
  
  ## Create dir in root partition for the persistant partition.  
  cd '/mnt'
  mkdir '.prst'
  
  ## Mount the persistant partition there
  DEVICE0='/dev/zvol/zvg1/PRST'
  mount -v --source $DEVICE0 --target '/mnt/.prst' --type 'xfs' -o 'defaults,iversion,noikeep,inode64,largeio,swalloc'
  
  ## Bind-mount etc
  cd '/mnt/.prst'
  mkdir 'etc'
  cd '/mnt'
  mkdir 'etc'
  mount -v --rbind '/mnt/.prst/etc' '/mnt/etc'
  
  ## Bind-mount home
  cd '/mnt/.prst'
  mkdir 'home'
  cd '/mnt'
  mkdir 'home'
  mount -v --rbind '/mnt/.prst/home' '/mnt/home'
  
  ## Bind-mount usr/local
  cd '/mnt/.prst'
  mkdir 'usr'
  cd '/mnt/.prst/usr'
  mkdir 'local'
  cd '/mnt'
  mkdir 'usr'
  cd '/mnt/usr'
  mkdir 'local'
  cd '/mnt'
  mount -v --rbind '/mnt/.prst/usr/local' '/mnt/usr/local'
  
  ## Bind-mount var
  cd '/mnt/.prst'
  mkdir 'var'
  cd '/mnt'
  mkdir 'var'
  mount -v --rbind '/mnt/.prst/var' '/mnt/var'
  
  ## Display partition-layout
  echo
  df -h
  echo "Pause for user-evaluation.  Press any key to continue.  "
  read
fi

### SCRIPTS NEEDED ------------------------------------------------------------------------------------

#TODO:  Auto-backup /boot every shutdown
#TODO:  Auto-snapshot XFS zpools every shutdown, keeping at most 3 snapshots.  
#TODO:  Auto-defrag XFS once in a while

### EXIT ----------------------------------------------------------------------------------------------

echo "Script complete.  "
exit 0

### EXAMPLES ------------------------------------------------------------------------------------------

## Create an XFS partition
## '-s' sets the sector-size, which is 4k in advanced-format disks (512 in older disks)
## '-b' sets the block-size, which should probably be a multiple of the sector size
## 'su' sets the stripe-unit, which should be a multiple of the block-size
## 'sw' sets the stripe-width, which is the number of devices
## 'su' and 'sw' don't normally need to be stated, but since we're making these partitions in a zpool, autodetection might not work
## '-i' sets the number of inodes, which should be 256 (128 is considered legacy, and isn't even allowed)
## 'projid32bit' enables 32-bit quota identifiers (the default is 16-bit)
## '-n version' has two options:  '2', which has normal UNIX-style naming, and 'ci', which has (buggy) Windows-style naming
## 
## All of the following options happen to be the default, except '-s', 'su', 'sw', 'maxpct', 'projid32bit', '-f'
mkfs.xfs -s 'size=4k' -b 'size=1s' -d 'su=1b,sw=2' -i 'maxpct=0,align=1,projid32bit=1' -l 'internal=1,su=1b' -f $DEVICE0
## 
## Mount options:  
OPTS="defaults,iversion,noikeep,inode64,largeio,swalloc"
## 
## Defragment the partition (do after installing and updating Arch)
xfs_fsr $DEVICE0
