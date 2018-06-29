#!/bin/bash

rsync -r --update --exclude-from '/vagrant/mysql-datadir/.backup_exclude' /var/lib/mysql/ /vagrant/mysql-datadir/
