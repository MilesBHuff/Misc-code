#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)

## Schedulers
tee /sys/block/sdc/queue/scheduler <<< noop
tee /sys/block/sr0/queue/scheduler <<< deadline

## SMART data
smartctl -s on -o on /dev/sda
