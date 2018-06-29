#!/bin/bash

#
# Prepare for building PHP and it's extensions
# This script must be invoked only if you need to (re-)build PHP yourself (it may take a lot of time).
#
#

export DEBIAN_FRONTEND=noninteractive

FBOLD=`tput bold`
FNORM=`tput sgr0`

echo "${FBOLD}Install development libs ...${FNORM}"

apt-get install -y apache2-dev libreadline-dev libc-client2007e-dev libxslt-dev libtidy-dev libedit-dev \
    libpspell-dev libsqlite3-dev unixodbc-dev libmysqlclient-dev libsasl2-dev libldb-dev libldap-dev libkrb5-dev \
    libfreetype6-dev libxpm-dev libpng-dev libpcre++-dev libjpeg-dev libbz2-dev libgnutls-openssl-dev libfcgi-dev \
    libmcrypt-dev libssl-dev libcurl4-openssl-dev pkg-config libxml2-dev librecode-dev libmhash-dev \
    libmemcached-dev libmagickwand-dev libmagickcore-dev libpq-dev >>/tmp/provision.log 2>&1

echo "${FBOLD}Install build essentials ...${FNORM}"

apt-get install -y checkinstall autoconf re2c >>/tmp/provision.log 2>&1
