#!/usr/bin/env bash
## For Bannerlord e1.0.2

## Download patched Proton (Thanks https://github.com/ValveSoftware/Proton/issues/3706#issuecomment-607065469)
COMPATD="$HOME/.steam/root/compatibilitytools.d"
ARCHIVE='proton_5.0-local.tar.gz'
mkdir -p "$COMPATD"
cd "$COMPATD"
curl "https://yellowapple-misc.s3-us-west-2.amazonaws.com/$ARCHIVE" -o "$ARCHIVE"
tar -xvf "$ARCHIVE"
rm  -f   "$ARCHIVE"
echo 'Please restart Steam and select this new Proton version for Bannerlord.'

## One person used these as their launch options, but they don't seem to do much of anything useful in my tests. (https://www.protondb.com/app/261550#jgkbMLpstU)
# PROTON_NO_ESYNC=1 gamemoderun %command% +in_terminal 1 +com_skipIntroVideo 1 +com_skipKeyPressOnLoadScreens 1 +com_skipSignInManager 1
