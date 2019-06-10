#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2019 per the LGPL3 (the Third Lesser GNU Public License)
## Sets the executable bit on all files with matching extensions at or below this directory
find . -type f |\
while read F; do
	if [[ -z $(echo "$F" | sed 's/^.*\.\(?:ba\(?:sh\|t\)\|exe\|msi\|p\(?:s1\|y\)\|sh\)$//') ]]; then
		echo "$F"
	fi
done |\
while read L; do
	chmod +x -c "$L"
done
