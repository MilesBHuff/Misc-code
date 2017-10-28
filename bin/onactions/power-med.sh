#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
# Set Granola Policy
/usr/bin/granola-set-policy /var/lib/miserware/policy.dat 16268 MiserWare
# Disable Desktop Composition
exec sh /home/sweyn78/.kde/scripts/disable-compositing.sh
