#!/usr/bin/env sh
## Copyright © by Miles Bradley Huff from 201?-2019 per the LGPL3 (the Third Lesser GNU Public License)
reflector -c 'US' --sort score --threads "$(nproc)" > '/etc/mirrorlist'
