#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
su -c "reflector -c US --sort score --threads 4 -p http > /etc/mirrorlist"
