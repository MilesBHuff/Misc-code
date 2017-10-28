#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
killall 'TESV.exe' &
pkill -9 'TESV.exe' &
cd "$HOME/My Games/Skyrim/Saves"
rm *.bak
cd '../Settings'
cp 'Skyrim.ini' '../Skyrim.ini'
cp 'SkyrimPrefs.ini' '../SkyrimPrefs.ini'
#"$HOME/.local/scripts/SetAudioSettings.sh" &
exec /usr/share/playonlinux/playonlinux --run 'skse_loader'
