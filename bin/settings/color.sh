#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201? per the LGPL3 (the Third Lesser GNU Public License)
/usr/bin/xiccd
/usr/bin/xcalib  ~/.color/icc/asus_vs247_native_user.icc &&
/usr/bin/xicc    ~/.color/icc/asus_vs247_native_user.icc
/usr/bin/xgamma  -rgamma 0.930 -ggamma 0.920 -bgamma 0.940
