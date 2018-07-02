#!/bin/bash

# Install supported PHP versions from ppa repository by Ondřej Surý

source /vagrant/scripts/setvars.sh

#if ! command -v pear >/dev/null; then
#  echo "${FBOLD}Install PHP Pear${FNORM}"
#  apt-get install -yq php-pear
#fi

# Install PHP 5.6-7.2 from Ondřej Surý PPA

PHP_VERSIONS=$1
PHP_EXTENSIONS=$2

if [[ ! -z $PHP_VERSIONS ]]; then

  PHP_VER_TOP=''

  # Add repositories
  
  if [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list ]; then
    echo "${FBOLD}Add Ondřej Surý PPA repository${FNORM}"
    add-apt-repository -y ppa:ondrej/php
    apt-get update -q
  fi

  for PHP_VERSION in $PHP_VERSIONS
  do
    a2dismod php${PHP_VERSION} >/dev/null 2>&1

    PHP_VERSION_STRIP=`echo $PHP_VERSION | sed "s/\.//g"`

    # Install PHP
    if [[ ! -f "/usr/bin/php${PHP_VERSION}" || ! -f "/usr/bin/php-cgi${PHP_VERSION}" ]]; then
      echo "${FBOLD}Install PHP ${PHP_VERSION} (Ondřej Surý PPA) ...${FNORM}"
      apt-get install -yq php${PHP_VERSION} php${PHP_VERSION}-cgi libapache2-mod-php${PHP_VERSION}
    fi

    if [[ ! -z $PHP_EXTENSIONS ]]; then
      # Install modules not already installed
      /usr/bin/php${PHP_VERSION} -m > /tmp/php_modules.txt
      for PHP_EXTENSION in $PHP_EXTENSIONS
      do
        EXT_NEEDLE=$PHP_EXTENSION
        if [ "$PHP_EXTENSION" = "mysql" ]; then
          EXT_NEEDLE="mysqlnd"
        fi
        if ! grep -w $EXT_NEEDLE /tmp/php_modules.txt >/dev/null; then
          echo "${FBOLD}Install php${PHP_VERSION}-${PHP_EXTENSION} extension (Ondřej Surý PPA) ...${FNORM}"
          apt-get install -yq "php${PHP_VERSION}-${PHP_EXTENSION}"
        fi
      done
    fi

  done
  
fi
