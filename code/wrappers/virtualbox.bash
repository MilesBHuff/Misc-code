#/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
if [ ! -f /tmp/vbox-dkms.lck ]; then
    gksudo modprobe vboxdrv vboxnetadp vboxnetflt
    cat "" > /tmp/vbox-dkms.lck
fi
VirtualBox %U
