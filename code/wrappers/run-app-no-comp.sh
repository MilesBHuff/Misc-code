#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
if [ "$1" != "" ]; then
	pkill -SIGTERM compton
	$1
	wait
	exec compton --config /home/sweyn78/.config/compton.conf &
	disown
	exit 0
else
	exit 1
fi
