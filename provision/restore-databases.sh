#!/bin/bash

source /vagrant/scripts/setvars.sh

# Xtrabackup

if [ ! -f /var/lib/mysql/.restored-from-backup ]; then
  echo "${TXHLT}Restore MySQL databases from last Xtrabackup dump${TXNORM}"
  if [[ -d /vagrant/backups/mysql-xtrabackup && -f /vagrant/backups/mysql-xtrabackup/xtrabackup_checkpoints ]]; then
    service mysql stop
    rm -rf /var/lib/mysql.old/
    mv /var/lib/mysql /var/lib/mysql.old
    xtrabackup --user=root --password=root --prepare --target-dir=/vagrant/backups/mysql-xtrabackup/
    xtrabackup --user=root --password=root --copy-back --target-dir=/vagrant/backups/mysql-xtrabackup/
    chown -R mysql:mysql /var/lib/mysql
    service mysql start
    echo "Xtrabackup dump restored."
    echo "Old MySQL datadir renamed to /var/lib/mysql.old/"
  else
    echo "MySQL Xtrabackup dump not found in backups/mysql-xtrabackup/"
  fi
  echo "Delete this file, if you need to force MySQL backup restore." >/var/lib/mysql/.restored-from-backup
else
  echo "No MySQL backup restored."
fi

echo "    Make new Xtrabackup dump:"
echo "        vagrant provision --provision-with backup-databases"
echo "    Restore last saved Xtrabackup dump:"
echo "        vagrant ssh -c 'sudo rm /var/lib/mysql/.restored-from-backup'"
echo "        vagrant provision --provision-with restore-databases"
