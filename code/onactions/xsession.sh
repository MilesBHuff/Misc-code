#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 2016-2019 per the LGPL3 (the Third Lesser GNU Public License)

## Daemons, systray, etc
#scrot /tmp/Scrot.png & \
#kstart kmix & \
#kstart klipper & \

## Update winecfg
#winecfg > /dev/null &
#sleep 8
#killall winecfg.exe

## Launch desktop environment
xterm -e  "
read -p 'Would you like to start common applications? (Y/n)' INPUT
[[ $INPUT = 'n' ]] && exit 1
exit 0"

## WEBS
sleep 4
kgtk-wrapper deluge-gtk > /dev/null & \
pithos > /dev/null & \
thunderbird-beta > /dev/null & \
firefox > /dev/null & \

## PILE
sleep 2
dolphin & \
atom & \
#terminator & \

## FULL
STEAM_FRAME_FORCE_CLOSE=1 steam > /dev/null & \

## CHAT
sleep 8
xchat > /dev/null & \
pidgin > /dev/null & \
kgtk-wrapper skype > /dev/null & \
