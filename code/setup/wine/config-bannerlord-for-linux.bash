#!/usr/bin/env bash
## For Bannerlord e1.0.2
set -e

## Find steamapps (necessary in case the game is installed on another drive)
if [[ ! -z $1 ]]; then
    STEAMAPPS="$1"
else
    STEAMAPPS="~/.steam/steam/steamapps"
fi

## Symlink EXEs (Thanks to https://www.protondb.com/app/261550#txbO8mhLD2 for the idea.)
cd "$STEAMAPPS/common/Mount & Blade II Bannerlord/bin/Win64_Shipping_Client"
ln -sfv 'Bannerlord_BE.exe' 'ManagedStarter_BE.exe'
ln -sfv 'Bannerlord.exe'    'ManagedStarter.exe'

## Change settings (Thanks to https://www.protondb.com/app/261550#3W0VKwtBY9 for the config path.)
cd "$STEAMAPPS/compatdata/261550/pfx/drive_c/users/steamuser/My Documents/Mount and Blade II Bannerlord/Configs"
FILE='engine_config.txt'
sed -i 's/^\(brightness_calibrated = \)0/\11/m' "$FILE" ## You'll get stuck on this screen if you aren't using a gamepad.
sed -i 's/^\(cheat_mode = \)0/\11/m'            "$FILE" ## It's extremely buggy -- you need cheats enabled to work around issues.
sed -i 's/^\(lighting_quality = \)2/\11/m'      "$FILE" ## Caused ghosting if set higher than 'Medium' during Beta; not sure if fixed. (I wrote about it here:  https://forums.taleworlds.com/index.php?threads/b0-2-8-weird-overlay-in-battles.388605/post-9174714)
echo 'Settings updated.'
