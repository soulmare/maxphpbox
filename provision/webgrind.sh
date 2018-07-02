#!/bin/bash

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
