#!/bin/sh
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)
cp -fv ./../mirrorlist /etc/pacman.d/
pacstrap -i /mnt base base-devel
genfstab -U /mnt > /mnt/etc/fstab
