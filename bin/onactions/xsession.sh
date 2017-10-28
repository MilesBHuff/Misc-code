#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 2016 per the LGPL3 (the Third Lesser GNU Public License)

## Launch desktop environment
sleep 4

#terminator -eH "sleep 6 ; killall terminator" &
#terminator -e  "echo 'Press [Return] to cancel start of basic applications' ; read ; killall DE.dash"

terminator -e  "echo 'Press [Return] to continue starting basic applications' ; read ; killall terminator"

## PRELIMINARIES
scrot /tmp/Scrot.png & \
# kstart kmix & \
kstart klipper & \
winecfg > /dev/null & sleep 8 ; killall winecfg.exe
## WEBS
/usr/bin/kgtk-wrapper deluge-gtk > /dev/null & \
pithos > /dev/null & \
thunderbird-beta > /dev/null & \
firefox > /dev/null & \
## PILE
sleep 2
dolphin & \
kate & \
#terminator & \
## FULL
STEAM_FRAME_FORCE_CLOSE=1 steam > /dev/null & \
## CHAT
sleep 8
xchat > /dev/null & \
pidgin > /dev/null & \
/usr/bin/kgtk-wrapper skype > /dev/null & \
