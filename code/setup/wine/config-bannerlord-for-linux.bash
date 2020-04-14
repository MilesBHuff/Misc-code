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
#cd "$STEAMAPPS/compatdata/261550/pfx/drive_c/users/steamuser/My Documents/Mount and Blade II Bannerlord/Configs"
#FILE='engine_config.txt'
#echo 'Settings updated.'
