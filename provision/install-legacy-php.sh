#!/bin/sh

PHP_VERSION="5.2"
PHP_INST="/opt/php/${PHP_VERSION}"

if [ ! -d PHP_INST ]; then

  echo "    Configure PHP $PHP_VERSION"
  dpkg -i /vagrant/files/deb/php-${PHP_VERSION}*.deb
  apt-get -fy install
  ln -s /opt/php/${PHP_VERSION}/bin/php-cgi /usr/bin/php-cgi${PHP_VERSION}
  ln -s /opt/php/${PHP_VERSION}/bin/php /usr/bin/php${PHP_VERSION}
  rm -f $PHP_INST/etc/php.ini
  ln -s /etc/php.ini $PHP_INST/etc/php.ini
  cp /vagrant/files/configs/usr.lib.cgi-bin.php-cgi /usr/lib/cgi-bin/php${PHP_VERSION}-cgi
  chmod +x /usr/lib/cgi-bin/php${PHP_VERSION}-cgi
  cp /vagrant/files/configs/etc.apache2.conf-available.php-cgi.conf /etc/apache2/conf-available/php${PHP_VERSION}-cgi.conf
  sed -i "s|%PHP_INST%|$PHP_INST|g" /usr/lib/cgi-bin/php${PHP_VERSION}-cgi /etc/apache2/conf-available/php${PHP_VERSION}-cgi.conf
  sed -i "s|%PHP_VERSION%|${PHP_VERSION}|g" /usr/lib/cgi-bin/php${PHP_VERSION}-cgi /etc/apache2/conf-available/php${PHP_VERSION}-cgi.conf
  echo '<?php phpinfo();' >/var/www/html/info-${PHP_VERSION}.php
  printf "<FilesMatch \"^info-${PHP_VERSION}.php$\">\n  SetHandler application/x-httpd-php${PHP_VERSION}\n</FilesMatch>\n" >>/var/www/html/.htaccess
  a2enconf php${PHP_VERSION}-cgi
  
  echo "Restart Apache ..."
  service apache2 restart

fi
