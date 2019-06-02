#!/bin/sh
clear
parted < "
select /dev/mmcblk0
unit %

mkpart
SWAP-SD

0
75

mkpart


75
100

q
"

clear
mke2fs -v -t  ext4 -O dir_index,extent,filetype,flex_bg,resize_inode,uninit_bg -I 128 -G 512 -m 1 -M /var /dev/mmcblk0p2
tune2fs -e remount-ro -o acl,bsdgroups,user_xattr /dev/mmcblk0p2
e2fsck -v -D /dev/mmcblk0p2

clear
mkdir /media/mmcblk0p2
mount /dev/mmcblk0p2 /media/mmcblk0p2
rm -rfv /media/mmcblk0p2/*
cp -dRv --preserve=all /media/sda1/var/* /media/mmcblk0p2
