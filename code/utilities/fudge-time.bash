#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
sudo date --set="$1"
for (( i=0; i<6; i++ )); do
	yes &
done
pkill -9 yes
touch -m "$2"
