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

  if ! command -v openssl >/dev/null; then
    echo "${FBOLD}Install Openssl${FNORM}"
    apt-get install -yq openssl
  fi

  # Add repositories
  
  if ! command -v add-apt-repository >/dev/null; then
    echo "${FBOLD}Install python-software-properties${FNORM}"
    apt-get install -yq python-software-properties
  fi
  
  if [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list ]; then
    echo "${FBOLD}Add Ondřej Surý PPA repository${FNORM}"
    add-apt-repository -y ppa:ondrej/php
  fi

  if [ ! -f /etc/apt/sources.list.d/sergey-dryabzhinsky-ubuntu-php52-xenial.list ]; then
    echo "${FBOLD}Add Sergey Dryabzhinsky PPA repositories${FNORM}"
    add-apt-repository -y ppa:sergey-dryabzhinsky/php52
    add-apt-repository -y ppa:sergey-dryabzhinsky/php52-modules
    add-apt-repository -y ppa:sergey-dryabzhinsky/php53
    add-apt-repository -y ppa:sergey-dryabzhinsky/php53-modules
    add-apt-repository -y ppa:sergey-dryabzhinsky/php54
    add-apt-repository -y ppa:sergey-dryabzhinsky/php54-modules
    add-apt-repository -y ppa:sergey-dryabzhinsky/php55
    add-apt-repository -y ppa:sergey-dryabzhinsky/php55-modules
    # Install dependencies for legacy PHPs
    echo "${FBOLD}Install dependencies for legacy PHP${FNORM}"
    wget -q -O /tmp/libmysqlclient18_5.6.25-0ubuntu1_amd64.deb http://launchpadlibrarian.net/212189159/libmysqlclient18_5.6.25-0ubuntu1_amd64.deb
    dpkg -i /tmp/libmysqlclient18_5.6.25-0ubuntu1_amd64.deb
    apt-get install -yq libmemcached-dev libmagickwand-dev
  fi

  apt-get update -q

  for PHP_VERSION in $PHP_VERSIONS
  do
    a2dismod php${PHP_VERSION} >/dev/null 2>&1

    PHP_VERSION_STRIP=`echo $PHP_VERSION | sed "s/\.//g"`

    if [[ "$PHP_VERSION" = "5.2" || "$PHP_VERSION" = "5.3" || "$PHP_VERSION" = "5.4" || "$PHP_VERSION" = "5.5" ]]; then
      PHP_LEGACY=true
    else
      PHP_LEGACY=false
    fi

    # Install PHP
    if [ $PHP_LEGACY == true ]; then
      if [ ! -f "/usr/bin/php${PHP_VERSION_STRIP}" ]; then
        echo "${FBOLD}Install PHP ${PHP_VERSION} (Sergey Dryabzhinsky PPA) ...${FNORM}"
        apt-get install -yq php${PHP_VERSION_STRIP}-cgi php${PHP_VERSION_STRIP}-cgi-daemon php${PHP_VERSION_STRIP}-cli php${PHP_VERSION_STRIP}-common php${PHP_VERSION_STRIP}-dev
        ln -s "/usr/bin/php${PHP_VERSION_STRIP}" "/usr/bin/php${PHP_VERSION}"
        ln -s "/usr/bin/php${PHP_VERSION_STRIP}-cgi" "/usr/bin/php${PHP_VERSION}-cgi"
        ln -s "/usr/bin/php${PHP_VERSION_STRIP}-modset" "/usr/bin/php${PHP_VERSION}-modset"
        ln -s "/usr/bin/php${PHP_VERSION_STRIP}-config" "/usr/bin/php${PHP_VERSION}-config"
        ln -s "/usr/bin/phpize${PHP_VERSION_STRIP}" "/usr/bin/phpize${PHP_VERSION}"
      fi
    else
      if [[ ! -f "/usr/bin/php${PHP_VERSION}" || ! -f "/usr/bin/php-cgi${PHP_VERSION}" ]]; then
        echo "${FBOLD}Install PHP ${PHP_VERSION} (Ondřej Surý PPA) ...${FNORM}"
        apt-get install -yq php${PHP_VERSION} php${PHP_VERSION}-cgi
      fi
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
          if [ $PHP_LEGACY == true ]; then
            # Some extensions aren't supported by legacy packages
            if [ "$PHP_EXTENSION" = "sqlite3" ]; then
              PHP_EXTENSION="sqlite"
            fi
            echo "${FBOLD}Install php${PHP_VERSION}-${PHP_EXTENSION} extension (Sergey Dryabzhinsky PPA) ...${FNORM}"
            apt-get install -yq "php${PHP_VERSION_STRIP}-mod-${PHP_EXTENSION}"
          else
            echo "${FBOLD}Install php${PHP_VERSION}-${PHP_EXTENSION} extension (Ondřej Surý PPA) ...${FNORM}"
            apt-get install -yq "php${PHP_VERSION}-${PHP_EXTENSION}"
          fi
#        else
#          echo "${FBOLD}php${PHP_VERSION}-${PHP_EXTENSION} extension already installed${FNORM}"
        fi
      done
    fi

    if [ $PHP_LEGACY == true ]; then

      # Unify ini files
      rm -rf /etc/php${PHP_VERSION_STRIP}/cgi/conf.d/
      ln -s /etc/php${PHP_VERSION_STRIP}/conf.d/ /etc/php${PHP_VERSION_STRIP}/cgi/conf.d
      rm -rf /etc/php${PHP_VERSION_STRIP}/cli/conf.d
      ln -s /etc/php${PHP_VERSION_STRIP}/conf.d/ /etc/php${PHP_VERSION_STRIP}/cli/conf.d

      # Compile extensions missing in packages
      /vagrant/scripts/php-ext-inst2.sh ${PHP_VERSION} xdebug 2.2.7
      /vagrant/scripts/php-ext-inst2.sh ${PHP_VERSION} memcached 2.1.0
      /vagrant/scripts/php-ext-inst2.sh ${PHP_VERSION} imagick 3.1.2
      if [ "$PHP_VERSION" = "5.2" ]; then
        /vagrant/scripts/php-ext-inst2.sh ${PHP_VERSION} phar 2.0.0
      fi

    fi

  done
  
fi
