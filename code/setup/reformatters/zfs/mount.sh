#!/usr/bin/env sh
zpool import -R "$MOUNTPOINT" "$ZPOOL"
zfs load-key "$ZPOOL"
zfs mount "$ZROOT"
zfs mount -a
