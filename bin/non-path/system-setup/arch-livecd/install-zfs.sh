#!/bin/sh

echo "INSTALLING ZFS STUFF -------------------------------------------------------"
dirmngr < /dev/null

echo
echo "ADDING REPO ----------------------------------------------------------------"
echo "[demz-repo-archiso]" >> /etc/pacman.conf
echo "Server = http://demizerone.com/\$repo/\$arch" >> /etc/pacman.conf

echo
echo "IMPORTING AND SIGNING KEY --------------------------------------------------"
pacman-key -r 0EE7A126
pacman-key --lsign-key 0EE7A126

echo
echo "UPDATING PACMAN AND INSTALLING archzfs -------------------------------------"
pacman -Syy --noconfirm archzfs-git

modprobe zfs
