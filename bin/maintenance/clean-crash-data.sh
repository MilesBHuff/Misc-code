#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
find ~'/core.'* -ctime +72 -exec mv {} ~'/.local/share/Trash/' \;
