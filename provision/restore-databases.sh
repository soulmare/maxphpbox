#!/bin/bash

if [ ! -d /var/lib/mysql/.restored-from-backup ]; then
  service mysql stop
  rsync -rog --chown=mysql:mysql --exclude ".*" /vagrant/mysql-datadir/* /var/lib/mysql/
  echo "This file in /var/lib/mysql/ is a flag signing that databases was restored from backup and are up to date" >/var/lib/mysql/.restored-from-backup
  service mysql start
fi