#!/bin/bash

# Attention!
# This removes Phpbrew downloaded and generated stuff - PHP sources, build directories etc.
# Also REMOVES ALL SUBDIRS within /opt/php directory.
# So, if you have some important .ini configs there, please take care to make backups first.

export DEBIAN_FRONTEND=noninteractive

# TODO: uninstall -dev libraries etc.

# TODO: uninstall custom php packages

FBOLD=`tput bold`
FNORM=`tput sgr0`

echo "${FBOLD}Purge PHP source and build directories ...${FNORM}"

rm -rf /home/vagrant/.phpbrew
rm -rf /root/.phpbrew
rm -rf /opt/php/5.*
rm -rf /opt/php/7.*
