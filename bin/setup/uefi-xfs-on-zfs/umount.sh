#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)

## Notify the user
echo "Attempting to umount partitions...  "

## Undo third wave
umount -v '/mnt/var'
umount -v '/mnt/usr/local'
umount -v '/mnt/home'
umount -v '/mnt/etc'
umount -v '/mnt/boot/bak'

## Undo second wave
umount -v '/mnt/.prst'
umount -v '/mnt/boot'

## Undo first wave
umount -v '/mnt'
swapoff -v '/dev/zvol/zvg0/SWAP'

## Export zpools
zpool export zvg1
zpool export zvg0

echo "Done.  "
