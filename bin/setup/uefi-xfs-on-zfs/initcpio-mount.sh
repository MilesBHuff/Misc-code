#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)
## A script to allow for mounting partitions in an initramfs.
## Computer-specific.

## Notify the user
echo ":: Mounting partitions..."

## First round
zpool import zvg0
zpool import zvg1

## Second round
swapon         '/dev/zvol/zvg0/SWAP'
mount --source '/dev/zvol/zvg1/ROOT' --target '/new_root'          --type 'xfs'  -o 'defaults,iversion,noikeep,inode64,largeio,swalloc'

# Third round
mount --source '/dev/sda1'           --target '/new_root/boot'     --type 'vfat' -o 'defaults,check=relaxed,tz=UTC,sys_immutable'
mount --source '/dev/zvol/zvg1/PRST' --target '/new_root/.prst'    --type 'xfs'  -o 'defaults,iversion,noikeep,inode64,largeio,swalloc'

# Fourth round
mount --source '/dev/sdb1'           --target '/new_root/boot/bak' --type 'vfat' -o 'defaults,check=relaxed,tz=UTC,sys_immutable'
mount --rbind  '/new_root/.prst/etc'          '/new_root/etc'
mount --rbind  '/new_root/.prst/home'         '/new_root/home'
mount --rbind  '/new_root/.prst/usr/local'    '/new_root/usr/local'
mount --rbind  '/new_root/.prst/var'          '/new_root/var'
