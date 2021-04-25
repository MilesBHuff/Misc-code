#!/bin/sh
## Written by Miles B Huff, Copyless (Ɔ) 2012 by CC0
clear
echo "Warning!  This script will REFORMAT partitions sda4, sda2, and sda1.  It may result in DATA LOSS.  Please ensure that important files have been backed up before you run this."
echo "This script should generally be run from a recovery CD."
echo "Do you really wish to run this script?"
echo "y/n"
read ANSWER
if $ANSWER = "n" ; then
  echo "Exiting now..."
  exit 0
fi
clear
echo "Formatting sda4 with ext4"
#Part1
mke2fs -v -t ext4 -O dir_index,extent,filetype,flex_bg,has_journal,large_file,resize_inode,sparse_super,uninit_bg -I 512 -G 4096 -M /home -J size=1000 /dev/sda4
#Part2
tune2fs -e remount-ro -m 1 -o acl,bsdgroups,user_xattr,journal_data /dev/sda4
#Part3
e2fsck -v -D /dev/sda4
#Done
read -p "Press the [Enter] key to continue..."
clear
echo "Formatting sda2 with xfs"
#Part1
mkfs.xfs -f -d agsize=65536000 -i maxpct=33,attr=2 -l lazy-count=1 /dev/sda2
#Part2
xfs_admin -e -L user -j /dev/sda2
#Part3
xfs_check /dev/sda2
#Done
read -p "Press the [Enter] key to continue..."
clear
echo "Formatting sda1 with reiserfs"
#Part1
mkreiserfs -f 3.6 -b 512 /dev/sda/1
#Part2
tunefs.reiserfs -l ROOT /dev/sda1
#Done
read -p "Press the [Enter] key to continue..."
clear
echo "Your disks have been sucessfully formatted."
exit 0
