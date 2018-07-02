#!/bin/bash

if [ ! -d /var/www/html/phpMyAdmin ]; then
  echo "${FBOLD}Install phpMyAdmin ...${TXNORM}"
  if [ ! -f /vagrant/files/apps/phpMyAdmin-4.8.2-all-languages.zip ]; then
    wget -q -O /vagrant/files/apps/phpMyAdmin-4.8.2-all-languages.zip https://files.phpmyadmin.net/phpMyAdmin/4.8.2/phpMyAdmin-4.8.2-all-languages.zip
  fi
  unzip -q -d /var/www/html/ /vagrant/files/apps/phpMyAdmin-4.8.2-all-languages.zip
  mv /var/www/html/phpMyAdmin* /var/www/html/phpMyAdmin
fi
