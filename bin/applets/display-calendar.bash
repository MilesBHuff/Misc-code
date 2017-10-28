#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)
DATE=$(date +'%_d')                         ## Store today's date in a variable
cal  -m --color=auto     >   /tmp/cal1.txt  ## Store this month's calendar in a file
tail -n +2 /tmp/cal1.txt >   /tmp/cal2.txt  ## Remove the header
rm /tmp/cal1.txt                            ## Remove unneeded files
head -n +1 /tmp/cal2.txt >>  /tmp/cal2.txt  ## Add the days of the week to the bottom (they're already at the top)
#sed -i    '/^$/d'           /tmp/cal2.txt  ## Remove blank lines
sed  -i    's/ '$DATE'/ ██/' /tmp/cal2.txt  ## Replace today's date with full-width blocks
sed  -i    's/^/   /'        /tmp/cal2.txt  ## Add 3 spaces before each line, for aesthetics
sed  -i -e 's/$/  /'         /tmp/cal2.txt  ## Add 2 spaces after each line, for aesthetics
echo '' && cat               /tmp/cal2.txt  ## Display the calendar
rm /tmp/cal2.txt                            ## Remove unneeded files
