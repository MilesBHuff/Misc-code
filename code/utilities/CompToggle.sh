#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
[ -f /tmp/psaux.txt ] && rm -f /tmp/psaux.txt
ps aux > /tmp/psaux.txt
if [ "$(cat /tmp/psaux.txt | grep compton)" != "" ]; then
	pkill -SIGTERM compton
else
	exec compton  --config ~/.config/compton.conf &
fi
[ -f /tmp/psaux.txt ] && rm -f /tmp/psaux.txt
exit 0
