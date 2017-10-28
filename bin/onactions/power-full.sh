#! /usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
# Set Granola Policy
/usr/bin/granola-set-policy /var/lib/miserware/policy.dat 16268 FullSpeed
# Enable Desktop Composition
exec sh  /home/sweyn78/.kde/scripts/enable-compositing.sh
