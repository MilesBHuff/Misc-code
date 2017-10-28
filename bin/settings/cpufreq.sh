#!/bin/sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
echo  'performance'  >  /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo  'powersave'    >  /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo  'performance'  >  /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo  'powersave'    >  /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
