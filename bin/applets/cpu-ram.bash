#!/usr/bin/env bash
################################################################################
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)
## This script extracts the current CPU utilization from the top utility, and
## then prints a representative bar to the terminal.

## Configuration-variables
declare DO_LOOP=true
declare DO_NEWLINES=true
declare DO_RAM=false
declare DO_VALUES=false

## The number of seconds between updates.
declare DELAY=0.1

## Parse arguments
if  [[ $1 != ''       ]] \
&&  [[ $1 != '-'*'1'* ]] \
&&  [[ $1 != '-'*'n'* ]] \
&&  [[ $1 != '-'*'r'* ]] \
&&  [[ $1 != '-'*'v'* ]]
then
	echo "Usage:  cpuram.bash [-1nrv]"
	exit 1
else
	[[ $1 == '-'*'1'* ]] && DO_LOOP=false
	[[ $1 == '-'*'n'* ]] && DO_NEWLINES=false
	[[ $1 == '-'*'r'* ]] && DO_RAM=true
	[[ $1 == '-'*'v'* ]] && DO_VALUES=true
fi

## Do the things
while true; do
	if [ $DO_RAM == false ]; then ## Requires procps-ng!
		declare -i CPU=0
		declare -i CORES="$(nproc)"
		declare    TOP='/tmp/top.out'
		echo "$(top -bd $DELAY -n 2 | grep '%Cpu' | tail -$CORES)" > "$TOP"
		while read L; do
			CPU=$CPU+"$(echo $L | sed 's/\[.*$//g' | tail -c 3 | xargs)"
		done < "$TOP"
		rm -f "$TOP"
		CPU=$CPU/$CORES
		unset CORES
		unset TOP

		if [ $DO_VALUES == true ]; then
			if [ $DO_NEWLINES == true ]; then
				echo    "${CPU}%"
			else
				echo -n "${CPU}%"
			fi
		else
			if [ $DO_NEWLINES == true ]; then
				if     [ $CPU -gt 63 ]; then
					if [ $CPU -gt 88 ]; then echo    '[oooo]'
					else                     echo    '[ooo ]'
					fi
				elif   [ $CPU -gt 13 ]; then
					if [ $CPU -gt 38 ]; then echo    '[oo  ]'
					else                     echo    '[o   ]'
					fi
				else                         echo    '[    ]'
				fi
			else
				if     [ $CPU -gt 63 ]; then
					if [ $CPU -gt 88 ]; then echo -n '[oooo]'
					else                     echo -n '[ooo ]'
					fi
				elif   [ $CPU -gt 13 ]; then
					if [ $CPU -gt 38 ]; then echo -n '[oo  ]'
					else                     echo -n '[o   ]'
					fi
				else                         echo -n '[    ]'
				fi
			fi
		fi
	else #TODO
		declare -i RAM=0
		declare -i TOTAL=0
		sleep $DELAY
		sleep $DELAY

		if [ $DO_VALUES == true ]; then
			if [ $DO_NEWLINES == true ]; then
				echo    "${RAM}%"
			else
				echo -n "${RAM}%"
			fi
		else
			if [ $DO_NEWLINES == true ]; then
				echo    '[    ]'
			else
				echo -n '[    ]'
			fi
		fi
	fi

	[ $DO_LOOP == false ] && exit 0
done
