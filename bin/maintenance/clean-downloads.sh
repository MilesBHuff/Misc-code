#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
find ~/Downloads/ -ctime +144 -exec mv {} ~/.local/share/Trash/ \;
cp -f ~/.local/share/directorybaks/downloads.directory ~/Downloads/.directory
cp -f ~/.local/share/directorybaks/downloads.directory ~/.local/share/Trash/.directory
