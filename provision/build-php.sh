#!/bin/bash

#
# Compile and install PHP of several versions with help of Phpbrew.
# To force recompiling please purge appropriate /opt/php/<version> directory 
#
# This script must be invoked only if you really need to (re-)build PHP yourself (it may take a lot of time).
# Instead, you can install them from .deb's, or even better - use Vagrant provisioners for this task.
# All compiled PHPs are installed into /opt/php/<version>.
# Also are created .deb PHP packages for possible latter use. But unfortunately, these .debs not include all needed
# libraries, though it's better to install them with a help of provisioner script, not manually.
#
#       Attention!
#  - Currently, NOT building Apache PHP modules. Only CLI and CGI/FastCGI are built.
#
# Known issues (Ubuntu 16.04):
#   PHP 5.2.17
#     - Mysqli shared library fails to load (mysqli.so: undefined symbol: client_errors in Unknown on line 0; look at https://forum.ispsystem.ru/showthread.php?32241-PHP-5-3-(alt)-%D0%BA%D0%B0%D0%BA-CGI-%D0%B2-%D0%BB%D0%BE%D0%B3%D0%B0%D1%85-%D1%81%D1%8B%D0%BF%D0%B5%D1%82-%D0%BE%D1%88%D0%B8%D0%B1%D0%BA%D0%B8&p=194197&viewfull=1#post194197)
#     - modules needs to compile: fileinfo, mysqli, mysqlnd
#

source /vagrant/scripts/setvars.sh

if [ -d /vagrant/files/deb ]; then
  echo "PHP packages directory exists. To force recompile packages, remove directory files/deb/"
  exit
fi

export DEBIAN_FRONTEND=noninteractive
export PATH="$PATH:/usr/bin/"

echo "${FBOLD}Install development libs ...${FNORM}"

apt-get install -y apache2-dev libreadline-dev libc-client2007e-dev libxslt-dev libtidy-dev libedit-dev \
    libpspell-dev libsqlite3-dev unixodbc-dev libmysqlclient-dev libsasl2-dev libldb-dev libldap-dev libkrb5-dev \
    libfreetype6-dev libxpm-dev libpng-dev libpcre++-dev libjpeg-dev libbz2-dev libgnutls-openssl-dev libfcgi-dev \
    libmcrypt-dev libssl-dev libcurl4-openssl-dev pkg-config libxml2-dev librecode-dev libmhash-dev \
    libmemcached-dev libmagickwand-dev libmagickcore-dev libpq-dev >>/tmp/provision.log 2>&1

echo "${FBOLD}Install build essentials ...${FNORM}"

apt-get install -y checkinstall autoconf re2c >>/tmp/provision.log 2>&1


#PHPBREW_CMD_FLAGS="--debug"
PHPBREW_CMD_FLAGS=""
#PHPBREW_FLAGS="--no-install"
PHPBREW_FLAGS=" --jobs `(grep processor /proc/cpuinfo | wc -l)`"
PHPBREW_CONFIGURE_OPTS="+default +ipv6 +ftp +hash +exif +cgi +session +imap +tidy +xmlrpc +zlib +gettext +iconv +soap +kerberos +gmp +opcache"
PHPBREW_CONFIGURE_OPTS_TILL_53="$PHPBREW_CONFIGURE_OPTS +gd +dbs"
PHPBREW_CONFIGURE_OPTS_TILL_54="$PHPBREW_CONFIGURE_OPTS_TILL_53 +apxs2"
PHPBREW_CONFIGURE_EXT_OPTS="--enable-force-cgi-redirect --disable-rpath --enable-gd-native-ttf --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr --with-icu-dir=/usr --enable-fastcgi --enable-spl --enable-wddx --with-layout=GNU --with-libedit --with-mime-magic --with-pic --with-pspell=shared --with-unixODBC=shared,/usr --with-xpm-dir=/usr --with-imap"

# When DRY_RUN=true, do not compile nothing, do not create packages
#DRY_RUN=true
DRY_RUN=false

if [ $DRY_RUN == true ]; then
  PHPBREW_FLAGS="--dryrun $PHPBREW_FLAGS"
fi

#declare -a PHP_VERSIONS_ALL=("5.2.17" "5.3.29" "5.6.36" "7.2.7")
#declare -a PHP_VERSIONS_ALL=("5.2.17" "5.3.29")
declare -a PHP_VERSIONS_ALL=("5.2.17" "5.3.29" "5.4.45" "5.5.38" "5.6.36" "7.0.30" "7.1.18" "7.2.7")


# Install phpbrew if it is not installed yet.
if ! command -v phpbrew >/dev/null; then
  echo "${TXHLT}Install Phpbrew ...${TXNORM}"
  wget -q -O /usr/local/bin/phpbrew https://github.com/phpbrew/phpbrew/raw/581eb9ce6434b870ef004a9d70c2ccc14f9d5ab7/phpbrew
  chmod +x /usr/local/bin/phpbrew
fi

if [ ! -f $HOME/.phpbrew/bashrc ]; then
  echo "${TXHLT}Init Phpbrew ...${TXNORM}"
  phpbrew init >/dev/null
  cp $HOME/.bashrc $HOME/.bashrc.bak
  printf "\nsource $HOME/.phpbrew/bashrc\n" | tee -a $HOME/.bashrc >/dev/null
  source $HOME/.phpbrew/bashrc
  phpbrew update --old >/dev/null
  #rm -rf /usr/local/bin/phpbrew; rm -rf .phpbrew/;export PATH="/home/vagrant/bin:/home/vagrant/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin";rm -rf /opt/php/;mv $HOME/.bashrc.bak $HOME/.bashrc
fi


# Symlinks needed for compiling older PHPs
#ln  -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a 2>/dev/null
ln  -s /usr/lib/libc-client.so.2007e.0 /usr/lib/x86_64-linux-gnu/libc-client.a 2>/dev/null
ln  -s /usr/lib/x86_64-linux-gnu/libpcre.a /usr/lib/libpcre.a 2>/dev/null
ln  -s /usr/lib/x86_64-linux-gnu/libjpeg.a /usr/lib/libjpeg.a 2>/dev/null
ln  -s /usr/lib/x86_64-linux-gnu/libpng.a /usr/lib/libpng.a 2>/dev/null
ln  -s /usr/lib/x86_64-linux-gnu/libXpm.a /usr/lib/libXpm.a 2>/dev/null
ln  -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so 2>/dev/null
ln  -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so 2>/dev/null
ln  -s /usr/include/editline/readline.h /usr/include/readline.h 2>/dev/null
ln  -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h 2>/dev/null
ln  -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl 2>/dev/null
ln  -s /usr/sbin/a2enmod /usr/bin/a2enmod 2>/dev/null
ln  -s /usr/sbin/a2dismod /usr/bin/a2dismod 2>/dev/null
ln  -s /usr/sbin/a2ensite /usr/bin/a2ensite 2>/dev/null
ln  -s /usr/sbin/a2dissite /usr/bin/a2dissite 2>/dev/null
if [ -f /usr/lib/x86_64-linux-gnu/libmysqlclient.so ]; then
  # MySQL
  ln  -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient.so 2>/dev/null
  if [ -f /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so ]; then
    ln  -s /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so /usr/lib/libmysqlclient_r.so 2>/dev/null
  else
    ln  -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/libmysqlclient_r.so 2>/dev/null
    ln  -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so 2>/dev/null
  fi
else
  # MariaDB as MySQL
  if [ -f /usr/lib/x86_64-linux-gnu/libmariadbclient.so ]; then
    ln  -s /usr/lib/x86_64-linux-gnu/libmariadbclient.so /usr/lib/libmysqlclient.so 2>/dev/null
    if [ -f /usr/lib/x86_64-linux-gnu/libmariadbclient_r.so ]; then
      ln  -s /usr/lib/x86_64-linux-gnu/libmariadbclient_r.so /usr/lib/libmysqlclient_r.so 2>/dev/null
    else
      ln  -s /usr/lib/x86_64-linux-gnu/libmariadbclient.so /usr/lib/libmysqlclient_r.so 2>/dev/null
      ln  -s /usr/lib/x86_64-linux-gnu/libmariadbclient.so /usr/lib/x86_64-linux-gnu/libmysqlclient_r.so 2>/dev/null
    fi
  fi
fi


if command -v php >/dev/null; then
      
  for (( i = 0; i < ${#PHP_VERSIONS_ALL[@]} ; i++ )); do

    PHP_VERSION="${PHP_VERSIONS_ALL[$i]}"
  
    a=( ${PHP_VERSION//./ } ) # replace points, split into array
    ((a[2]++)) # increment revision (or other part)
    PHP_VERSION_MAJOR="${a[0]}.${a[1]}" # shorten version
    PHP_VERSION_MAJOR2="${a[0]}" # 1st version digit
  
    PHP_PATH=/opt/php/$PHP_VERSION_MAJOR  

    # Compile PHP only if it is not installed yet
    if ! $PHP_PATH/bin/php -v >/dev/null 2>&1; then

      PHP_CONFIGURE_PATHS="--prefix=$PHP_PATH --exec-prefix=$PHP_PATH --sysconfdir=$PHP_PATH/etc --with-config-file-path=$PHP_PATH/etc --with-config-file-scan-dir=$PHP_PATH/etc/php.d --with-pear=$PHP_PATH/lib/php/pear"
      mkdir -p /vagrant/files/php/$PHP_VERSION_MAJOR/
      mkdir -p /opt/php
      if [ ! $DRY_RUN == true ]; then
        rm -rf $PHP_PATH
      fi
  #      chmod go+w -R /usr/lib/apache2/modules /etc/apache2/
  
      #--post-clean --test --dryrun
      case "$PHP_VERSION_MAJOR" in 
          5.2 )
              echo "${TXHLT}Compile PHP $PHP_VERSION (stage 1 of 2: apxs2 target) ...${TXNORM}"
              phpbrew $PHPBREW_CMD_FLAGS install $PHPBREW_FLAGS --old --name $PHP_VERSION_MAJOR \
                  --patch /vagrant/files/php/patches/node.patch \
                  --patch /vagrant/files/php/patches/openssl.patch \
                  --patch /vagrant/files/php/patches/gmp.patch \
                  $PHP_VERSION $PHPBREW_CONFIGURE_OPTS +apxs2 -cli -cgi \
                  -- $PHPBREW_CONFIGURE_EXT_OPTS $PHP_CONFIGURE_PATHS \
                  --with-sqlite=shared --with-mysqli=shared,/usr/bin/mysql_config --with-mysql=shared,/usr --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-pdo-mysql=shared --with-pdo-odbc=shared,unixODBC,/usr --with-pdo-sqlite=shared --with-gd
              if [ ! $? -eq 0 ]; then
                echo "${FBOLD}${CLRED}ERROR: compilation (apxs2 target) failed${TXNORM}"
                exit 1
              fi
              echo "${TXHLT}Compile PHP $PHP_VERSION (stage 2 of 2: CLI/CGI targets) ...${TXNORM}"
              phpbrew $PHPBREW_CMD_FLAGS install $PHPBREW_FLAGS --old --name $PHP_VERSION_MAJOR \
                  --patch /vagrant/files/php/patches/node.patch \
                  --patch /vagrant/files/php/patches/openssl.patch \
                  --patch /vagrant/files/php/patches/gmp.patch \
                  $PHP_VERSION $PHPBREW_CONFIGURE_OPTS -apxs2 \
                  -- $PHPBREW_CONFIGURE_EXT_OPTS $PHP_CONFIGURE_PATHS \
                  --with-sqlite=shared --with-mysqli=shared,/usr/bin/mysql_config --with-mysql=shared,/usr --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-pdo-mysql=shared --with-pdo-odbc=shared,unixODBC,/usr --with-pdo-sqlite=shared --with-gd
              ;;
          5.3 )
              echo "${TXHLT}Compile PHP $PHP_VERSION (stage 1 of 2: apxs2 target) ...${TXNORM}"
              phpbrew $PHPBREW_CMD_FLAGS install $PHPBREW_FLAGS --name $PHP_VERSION_MAJOR \
                  $PHP_VERSION $PHPBREW_CONFIGURE_OPTS_TILL_53 +apxs2 -cli -cgi \
                  -- $PHPBREW_CONFIGURE_EXT_OPTS $PHP_CONFIGURE_PATHS
              if [ ! $? -eq 0 ]; then
                echo "${FBOLD}${CLRED}ERROR: compilation (apxs2 target) failed${TXNORM}"
                exit 1
              fi
              echo "${TXHLT}Compile PHP $PHP_VERSION (stage 2 of 2: CLI/CGI targets) ...${TXNORM}"
              phpbrew $PHPBREW_CMD_FLAGS install $PHPBREW_FLAGS --name $PHP_VERSION_MAJOR \
                  $PHP_VERSION $PHPBREW_CONFIGURE_OPTS_TILL_53 -apxs2 \
                  -- $PHPBREW_CONFIGURE_EXT_OPTS $PHP_CONFIGURE_PATHS
              ;;
          5.4 | 5.5 | 5.6 | 7.0 | 7.1 | 7.2 | 7.3 )
              echo "${TXHLT}Compile PHP $PHP_VERSION (all targets: CLI/CGI/apxs2) ...${TXNORM}"
              phpbrew $PHPBREW_CMD_FLAGS install $PHPBREW_FLAGS --name $PHP_VERSION_MAJOR \
                  $PHP_VERSION $PHPBREW_CONFIGURE_OPTS_TILL_54 \
                  -- $PHPBREW_CONFIGURE_EXT_OPTS $PHP_CONFIGURE_PATHS
              ;;
      esac
  
      # If compiled successfully
      if [ $? -eq 0 ]; then

        # Rename php<X>.load to php<X>.<X>.load to avoid naming collisions
        mv /etc/apache2/mods-available/php${PHP_VERSION_MAJOR2}.load /etc/apache2/mods-available/php${PHP_VERSION_MAJOR}.load
  
        # Copy sample ini files
        mkdir -p $PHP_PATH/etc/
        cp $HOME/.phpbrew/build/$PHP_VERSION_MAJOR/php.ini* $PHP_PATH/etc/
#        if [ -f $HOME/.phpbrew/build/$PHP_VERSION_MAJOR/php.ini-development ]; then
#          cp $HOME/.phpbrew/build/$PHP_VERSION_MAJOR/php.ini-development $PHP_PATH/etc/php.ini
#        else
#          if [ -f $HOME/.phpbrew/build/$PHP_VERSION_MAJOR/php.ini-dist ]; then
#            cp $HOME/.phpbrew/build/$PHP_VERSION_MAJOR/php.ini-dist $PHP_PATH/etc/php.ini
#          fi
#        fi
        
        # Install extensions
        # Xdebug 2.2.7 seems to be the topmost version with PHP 5.2 support
        # Xdebug 2.5.5 is compatible with PHP 5.5+
        # Xdebug 2.6+ is compatible with PHP 7+
        # Xdebug 2.3.0 is compatible with PHP 5.4+
        # php-memcached 2.x: Supports PHP 5.2 - 5.6. Besides, 2.2.0 fails to compile with PHP 5.2.17
        # php-memcached 3.x: Supports PHP 7.0 - 7.1
        # Phar needs to be installed only for PHP 5.2.17, as in PHP 5.3+ it is integrated in core
  
        echo "${TXHLT}Compile extensions for PHP $PHP_VERSION ...${TXNORM}"
  
        if [ ! $DRY_RUN == true ]; then
  
          case "$PHP_VERSION_MAJOR" in 
              5.2 )
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR xdebug 2.2.7
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR memcached 2.1.0
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR imagick 3.1.2
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR phar 2.0.0
                  ;;
              5.3 )
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR xdebug 2.2.7
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR memcached 2.2.0
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR imagick 3.1.2
                  ;;
              5.4 | 5.5 | 5.6 )
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR xdebug 2.3.3
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR memcached 2.2.0
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR imagick 3.4.3
                  ;;
              7.0 | 7.1 | 7.2 | 7.3 )
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR xdebug 2.6.0
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR memcached 3.0.4
                  /vagrant/scripts/./php-ext-inst.sh $PHP_VERSION_MAJOR imagick 3.4.3
                  ;;
          esac
  
          # Enable all installed extensions
          /vagrant/scripts/./php-enext.sh
    
          # Save PHP tech info (after installing extensions!)
          $PHP_PATH/bin/php -i >/vagrant/files/php/$PHP_VERSION_MAJOR/phpinfo.txt 2>&1
          $PHP_PATH/bin/php -m >/vagrant/files/php/$PHP_VERSION_MAJOR/modules.txt 2>&1
        
        fi
      
  #set +o xtrace
      else
        echo "${FBOLD}${CLRED}ERROR: compilation failed on PHP $PHP_VERSION ${TXNORM}"
        exit 1
      fi

    else

        echo "Check: PHP $PHP_VERSION_MAJOR is installed, skip"
    
    fi

  done

else

  echo "${FBOLD}${CLRED}ERROR: System PHP not installed${TXNORM}"

fi
