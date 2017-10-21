#!/usr/bin/sh
su -c "reflector -c US --sort score --threads 4 -p http > /etc/mirrorlist"
