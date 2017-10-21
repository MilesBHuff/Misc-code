#!/bin/sh
cp -fv ./../mirrorlist /etc/pacman.d/
pacstrap -i /mnt base base-devel
genfstab -U /mnt > /mnt/etc/fstab
