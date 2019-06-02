#!/usr/bin/env bash
## Pretty-prints a calendar.
## Copyright © by Miles Bradley Huff from 2016-2019 per the LGPL3 (the Third Lesser GNU Public License)

## Create a tempfile to work on
TEMP="/tmp/$((9999 + RANDOM % 99999999)).tmp"

## Store this month's calendar in the tempfile
cal > "$TEMP"

## Remove the header
tail -n +2 "$TEMP" > "$TEMP.new"
mv "$TEMP.new" "$TEMP"

## Add the days of the week to the bottom (they're already at the top)
head -n +1 "$TEMP" >> "$TEMP"

## Remove blank lines
sed -ir 's/^\s*$//gm' "$TEMP" ##TODO:  Not working.

## Replace today's date with full-width blocks
DATE="$(date +'%_d')"
sed -ir 's/ '"$DATE"'/ ██/gm' "$TEMP"

## Add 3 spaces before each line, for aesthetics
sed -ir 's/^/   /gm' "$TEMP"

## Add 2 spaces after each line, for aesthetics
sed -ir 's/$/  /gm' "$TEMP"

## Display the calendar
echo && cat "$TEMP"

## Remove the tempfile
rm "$TEMP"

## Exit successfully
exit 0
