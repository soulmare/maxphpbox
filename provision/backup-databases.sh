#!/bin/bash

source /vagrant/scripts/setvars.sh

# Xtrabackup

echo "${TXHLT}Backup MySQL databases via Xtrabackup${TXNORM}"

# Remove previous backup if present
rm -rf /vagrant/backups/mysql-xtrabackup.old
mv /vagrant/backups/mysql-xtrabackup /vagrant/backups/mysql-xtrabackup.old 2>/dev/null
mkdir -p /vagrant/backups/mysql-xtrabackup

xtrabackup --user=root --password=root --backup \
    --target-dir=/vagrant/backups/mysql-xtrabackup/

echo "Xtrabackup MySQL backup saved in backups/mysql-xtrabackup/"
echo "Old backup, if present, was renamed to backups/mysql-xtrabackup.old/"

#    --databases-exclude=performance_schema \
#    --databases-exclude=sys \
#    --databases-exclude=mysql \
