#!/usr/bin/env bash
function f {
	local -i I=0
	while true; do
		I=$I+1
		echo
		echo $I
		pkill -SIGUSR1 dd
		sleep 10
	done
	echo
}
dd if=$1 of=$2 &
f
exit 0
