#!/bin/bash

#
# Install basic web-development essentials and LAMP server components
#

export DEBIAN_FRONTEND=noninteractive


FBOLD=`tput bold`
FNORM=`tput sgr0`

echo "${FBOLD}Update apps ...${FNORM}"
apt-get update -q && apt-get upgrade -yq

if ! command -v mysql >/dev/null; then
  echo "${FBOLD}Install MySQL ...${FNORM}"
  # Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
  echo "mysql-server-5.7 mysql-server/root_password password root" | debconf-set-selections
  echo "mysql-server-5.7 mysql-server/root_password_again password root" | debconf-set-selections
  apt-get install -yq mysql-client-5.7 mysql-server-5.7
  # Setup MySQL
  # Allow access for root user without password
  cp /vagrant/files/configs/my.cnf /etc/mysql/my.cnf
  # Allow access to MySQL from any host
  mysql -uroot -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'root';FLUSH PRIVILEGES"
  patch -bsN -r - /etc/mysql/mysql.conf.d/mysqld.cnf /vagrant/files/configs/mysqld.cnf.patch >/dev/null
  #mysql -uroot -proot < "CREATE USER 'root'@'%' IDENTIFIED BY 'root';GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;FLUSH PRIVILEGES"
  service mysql restart
fi

echo "${FBOLD}Install Sqlite ...${FNORM}"
apt-get install -yq sqlite3

echo "${FBOLD}Install Ruby ...${FNORM}"
apt-get install -yq ruby

echo "${FBOLD}Install utilities ...${FNORM}"
apt-get install -yq vim curl composer git htop zip g++

echo "${FBOLD}Install LAMP components ...${FNORM}"
apt-get install -yq apache2 php libapache2-mod-php php-mysql php-mcrypt php-bcmath php-imap php-mbstring php-pspell php-soap php-curl php-gd php-gmp php-odbc php-sqlite3 php-tidy php-zip php-xmlrpc php-bz2 php-xml php-xdebug php-memcached php-imagick php-pear libfcgi0ldbl imagemagick memcached

# Suppress possible error message from Vagrant
echo ""
