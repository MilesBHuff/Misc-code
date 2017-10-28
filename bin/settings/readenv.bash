#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)

DEBUG=0

## Read locale
while read LINE; do
    export "$LINE"
    [[ DEBUG -eq 1 ]] && echo "$LINE"
done < '/etc/locale.conf'

## Read environment
while read LINE; do
    export "$LINE"
    [[ DEBUG -eq 1 ]] && echo "$LINE"
done < '/etc/environment'

## Read .pam_environment
while read LINE; do
    export "$LINE"
    [[ DEBUG -eq 1 ]] && echo "$LINE"
done < "$HOME/.pam_environment"

## unset bad variables
source '/home/sweyn78/.local/scripts/unsetvars.sh'
