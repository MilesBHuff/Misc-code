#!/usr/bin/env sh
zpool import -R '/mnt' 'linux'
zfs load-key 'linux'
zfs mount 'linux'
zfs mount -a
