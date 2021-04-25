#!/bin/sh
## This script creates certain potentially missing directories on a linux system

## Aliases
alias  md='mkdir -p'
alias smd='sudo md'

## Caches
 md ~/.compose-cache
smd /var/cache/libx11/compose

## .local
 md ~/.local/bin
 md ~/.local/lib
 md ~/.local/opt
 md ~/.local/share
 md ~/.local/src

## Fonts
smd             /usr/share/fonts
 md                     ~/.fonts
smd             /etc/skel/.fonts
smd       /usr/local/share/fonts
 md         ~/.local/share/fonts
smd /etc/skel/.local/share/fonts

## Fontconfig
smd       /var/cache/fontconfig
 md         ~/.cache/fontconfig
smd /etc/skel/.cache/fontconfig
 md               ~/.fontconfig
smd       /etc/skel/.fontconfig
