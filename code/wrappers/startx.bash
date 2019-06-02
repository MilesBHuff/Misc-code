#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)

## Start X if not currently running
if [[ ${#$(pidof X)} -gt 0 ]] || [[ -e '/tmp/.X11-unix/X0' ]]; then
	echo 'X is already running'
else
#elif [[ ! ${DISPLAY} ]] && [[ ${XDG_VTNR} == 7 ]]; then
	exec startx -- vt07 -nolisten tcp
fi
