#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

source /vagrant/scripts/setvars.sh


echo "${FBOLD}Configure Apache ...${TXNORM}"


if [ ! -f /etc/php.ini ]; then 
  cp /vagrant/files/configs/php.ini /etc/php.ini
fi
patch -bsN -r - /etc/apache2/apache2.conf /vagrant/files/configs/etc.apache2.apache2.conf.patch
cp /vagrant/files/configs/etc.apache2.sites-available.000-default.conf /etc/apache2/sites-available/000-default.conf

rm -f /var/www/html/.htaccess
mv -f /var/www/html/index.html /var/www/html/index-default.html 2>/dev/null
echo '<?php phpinfo();' >/var/www/html/info.php
cp -n /vagrant/scripts/php-mail-test.php /var/www/html/

a2dismod mpm_event 2>/dev/null
a2enmod rewrite actions cgi mpm_prefork

PHP_VERSIONS=$1
PHP_VERSION=''

for PHP_VERSION in $PHP_VERSIONS
do
  echo "    Configure PHP $PHP_VERSION"

  a2dismod php${PHP_VERSION}
  ln -s /etc/php.ini /etc/php/$PHP_VERSION/apache2/conf.d/00-php.ini 2>/dev/null
  cp /vagrant/files/configs/usr.lib.cgi-bin.php-cgi /usr/lib/cgi-bin/php${PHP_VERSION}-cgi
  chmod +x /usr/lib/cgi-bin/php${PHP_VERSION}-cgi
  cp /vagrant/files/configs/etc.apache2.conf-available.php-cgi.conf /etc/apache2/conf-available/php${PHP_VERSION}-cgi.conf
  sed -i "s|%PHP_VERSION%|${PHP_VERSION}|g" /usr/lib/cgi-bin/php${PHP_VERSION}-cgi /etc/apache2/conf-available/php${PHP_VERSION}-cgi.conf
  echo '<?php phpinfo();' >/var/www/html/info-${PHP_VERSION}.php
  printf "<FilesMatch \"^info-${PHP_VERSION}.php$\">\n  SetHandler application/x-httpd-php${PHP_VERSION}\n</FilesMatch>\n" >>/var/www/html/.htaccess
  a2enconf php${PHP_VERSION}-cgi

done

# Enable highest version PHP as default module
if [ ! -z $PHP_VERSION ]; then
  a2enmod php${PHP_VERSION} >/dev/null
fi

exit

if [ ! -d /var/www/html/webgrind ]; then
  echo "${FBOLD}Install Webgrind ...${TXNORM}"
  cd /var/www/html/
  if [ ! -f /vagrant/files/apps/webgrind-v1.5.0.zip ]; then
    wget -q -O /vagrant/files/apps/webgrind-v1.5.0.zip https://github.com/jokkedk/webgrind/archive/v1.5.0.zip
  fi
  cp /vagrant/files/apps/webgrind-v1.5.0.zip .
  unzip -q webgrind-v1.5.0.zip
  rm webgrind-v1.5.0.zip
fi

if [ ! -d /var/www/html/phpMyAdmin ]; then
  echo "${FBOLD}Install phpMyAdmin ...${TXNORM}"
  if [ ! -f /vagrant/files/apps/phpMyAdmin-4.8.2-all-languages.zip ]; then
    wget -q -O /vagrant/files/apps/phpMyAdmin-4.8.2-all-languages.zip https://files.phpmyadmin.net/phpMyAdmin/4.8.2/phpMyAdmin-4.8.2-all-languages.zip
  fi
  unzip -q -d /var/www/html/ /vagrant/files/apps/phpMyAdmin-4.8.2-all-languages.zip
  mv /var/www/html/phpMyAdmin* /var/www/html/phpMyAdmin
fi

chown -R vagrant:vagrant /var/www/html/

# Create test virtual host
mkdir -p /vagrant/vhosts/test.local

echo "Restart Apache ..."
service apache2 restart
