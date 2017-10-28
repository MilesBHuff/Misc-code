#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)

## A script to allow for mounting partitions from a flashdrive.
## Computer-specific.

## Notify the user
# echo ":: Mounting partitions..."

## Variables
XFS_OPTS='defaults,rw,relatime,lazytime,swalloc,attr2,noikeep,largeio,inode64,iversion,sunit=8,swidth=16,noquota'
VFAT_OPTS='defaults,rw,relatime,lazytime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,check=relaxed,sys_immutable,tz=UTC,errors=remount-ro'

## First round
zpool import -f zvg0
zpool import -f zvg1
sleep 2

## Second round
swapon -p 0             '/dev/zvol/zvg0/SWAP'
mount                   '/dev/zvol/zvg1/ROOT' '/mnt'
sleep 1

## Third round
mount                   '/dev/sda1'           '/mnt/boot'
mount                   '/dev/zvol/zvg1/PRST' '/mnt/.prst'
sleep 1

## Fourth round
mount                   '/dev/sdb1'            '/mnt/boot/bak'
mount --bind            '/mnt/.prst/etc'       '/mnt/etc'
mount --bind            '/mnt/.prst/home'      '/mnt/home'
mount --bind            '/mnt/.prst/usr/local' '/mnt/usr/local'
mount --bind            '/mnt/.prst/var'       '/mnt/var'
