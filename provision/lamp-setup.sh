#!/bin/bash

# TODO:
#- !! install package only if newer version
#- ?? special extensions .php${PHP_VERSION_MAJOR} etc.
#- check if default .ini excluded from package
#- Check make's suggestion: "You may want to add: /opt/php/<version>/lib/php/pear to your php.ini include_path"

#cp /opt/php/5.3/etc/php.ini-development /opt/php/5.2/etc/php.d/00-php.development.ini

export DEBIAN_FRONTEND=noninteractive

source /vagrant/scripts/setvars.sh

# If DRYRUN=true, nothing is installed, only configuration is performed
DRYRUN=false

if [ -f /root/.php_packages_installed ]; then
  DRYRUN=true
fi


if ! $DRYRUN; then

  echo "${TXHLT}Install dependencies for custom PHP packages  ...${TXNORM}"

  PACKAGES=/vagrant/files/deb/php-*.deb
  DEPS_LIST=""
  
  for PACKAGE in $PACKAGES
  do
    DEPS_LIST="$DEPS_LIST $(dpkg -f /vagrant/files/deb/php-*.deb Depends | sed 's/,//g' | sed 's/Depends://g')"
  done
  
  apt-get install -yq $(dpkg -f /vagrant/files/deb/php-*.deb Depends | sed 's/,//g' | sed 's/Depends://g')
  
  echo "${TXHLT}Install custom PHP packages  ...${TXNORM}"
  
  dpkg -i /vagrant/files/deb/php*
  touch /root/.php_packages_installed

fi

echo "${TXHLT}Configure Apache to work with installed custom PHPs ...${TXNORM}"


if [ ! -f /etc/php.ini ]; then 
  cp /vagrant/files/configs/php.ini /etc/php.ini
fi
patch -bsN -r - /etc/apache2/apache2.conf /vagrant/files/configs/etc.apache2.apache2.conf.patch
cp /vagrant/files/configs/etc.apache2.sites-available.000-default.conf /etc/apache2/sites-available/000-default.conf

rm -f /var/www/html/.htaccess
mv -f /var/www/html/index.html /var/www/html/index-default.html 2>/dev/null
echo '<?php phpinfo();' >/var/www/html/info.php
cp -n /vagrant/scripts/php-mail-test.php /var/www/html/

sed -i 's/libphp7.0.30.so/libphp7.0.so/' /etc/apache2/mods-available/php7.0.load

a2dismod mpm_event php5 php7 2>/dev/null
a2enmod rewrite actions cgi mpm_prefork php7.0

if [ ! -f /etc/php/7.0/apache2/php.ini.bak ]; then
  mv /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini.bak
  ln -s /etc/php.ini /etc/php/7.0/apache2/php.ini
fi

PHP_INST_FOLDERS=/opt/php/*

for PHP_INST in $PHP_INST_FOLDERS
do
	PHP_VER=`$PHP_INST/bin/php-config --version`
  a=( ${PHP_VER//./ } ) # replace points, split into array
  ((a[2]++)) # increment revision (or other part)
  PHP_VERSION_MAJOR="${a[0]}.${a[1]}" # shorten version
  echo "    Configure PHP $PHP_VERSION_MAJOR"

  rm -f $PHP_INST/etc/php.ini
  ln -s /etc/php.ini $PHP_INST/etc/php.ini
  cp /vagrant/files/configs/usr.lib.cgi-bin.php-cgi /usr/lib/cgi-bin/php${PHP_VERSION_MAJOR}-cgi
  chmod +x /usr/lib/cgi-bin/php${PHP_VERSION_MAJOR}-cgi
  cp /vagrant/files/configs/etc.apache2.conf-available.php-cgi.conf /etc/apache2/conf-available/php${PHP_VERSION_MAJOR}-cgi.conf
  sed -i "s|%PHP_INST%|$PHP_INST|g" /usr/lib/cgi-bin/php${PHP_VERSION_MAJOR}-cgi /etc/apache2/conf-available/php${PHP_VERSION_MAJOR}-cgi.conf
  sed -i "s|%PHP_VERSION_MAJOR%|${PHP_VERSION_MAJOR}|g" /usr/lib/cgi-bin/php${PHP_VERSION_MAJOR}-cgi /etc/apache2/conf-available/php${PHP_VERSION_MAJOR}-cgi.conf
  echo '<?php phpinfo();' >/var/www/html/info-${PHP_VERSION_MAJOR}.php
  printf "<FilesMatch \"^info-${PHP_VERSION_MAJOR}.php$\">\n  SetHandler application/x-httpd-php${PHP_VERSION_MAJOR}\n</FilesMatch>\n" >>/var/www/html/.htaccess
  a2enconf php${PHP_VERSION_MAJOR}-cgi

done


if [ ! -d /var/www/html/webgrind ]; then
  echo "Install Webgrind"
  cd /var/www/html/
  if [ ! -f /vagrant/files/apps/webgrind-v1.5.0.zip ]; then
    wget -q -O /vagrant/files/apps/webgrind-v1.5.0.zip https://github.com/jokkedk/webgrind/archive/v1.5.0.zip
  fi
  cp /vagrant/files/apps/webgrind-v1.5.0.zip .
  unzip webgrind-v1.5.0.zip
  rm webgrind-v1.5.0.zip
fi

chown -R vagrant:vagrant /var/www/html/

# Create test virtual host
mkdir -p /vagrant/vhosts/test.local

echo "Restart Apache ..."
service apache2 restart
