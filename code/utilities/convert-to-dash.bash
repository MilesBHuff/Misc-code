#!/usr/bin/env bash
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
find {,/usr}/bin -type f \
    -exec grep -q -- '^#!/bin/sh' {} \; \
    -exec /home/cuil78/Downloads/checkbashisms -f -p {} + \
    -fls /tmp/fusrodah.txt
sed 's/^.\{69\}//g' /tmp/fusrodah.txt
## Dangeruos stuff
N=1
LINES=`wc -l "/tmp/fusrodah.txt" | awk '{print $1'}`
until [[ $N > $LINES ]]; do
  cat /tmp/fusrodah.txt | head $N | tail '1' > FILE
  echo ${$FILE//'#!/bin/sh'/'#!/bin/bash'} > $FILE
  N=$N+1
done
