#!/bin/bash

# Install PHP extension for selected PHP version

LOGFILE="/tmp/`basename "$0"`.log"

if [ "$#" -ne 3 ]; then
  echo "Install PHP extension"
  echo "      Usage: ./`basename "$0"` <php version> <extension name> <extension version>"
  echo "    The needed extension must be available at https://pecl.php.net/get/<extension name>-<extension version>.tgz"
  echo "    It will be downloaded, compiled and installed into '/opt/php/<php version>/...path_to_libraries.../' directory"
  echo "    To enable new extension usually you must add 'extension=<extension name>.so' to corresponding .ini file,"
  echo "    or do it automatically for all PHPs stack with '$ /vagrant/scripts/./php-enext.sh'"
  exit
fi

PHP_VERSION=${BASH_ARGV[2]}
EXT_NAME=${BASH_ARGV[1]}
EXT_VERSION=${BASH_ARGV[0]}
EXT_SRC="/usr/local/src/${EXT_NAME}-${EXT_VERSION}/"
EXT_URL="https://pecl.php.net/get/${EXT_NAME}-${EXT_VERSION}.tgz"

echo "Install ${EXT_NAME}-${EXT_VERSION} extension for PHP $PHP_VERSION ..."

if [ ! -d "$EXT_SRC" ]; then
  cd /usr/local/src/
  #sudo wget http://xdebug.org/files/${EXT_NAME}-${EXT_VERSION}.tgz
  echo "    Get $EXT_URL ..."
  sudo wget -q -O ${EXT_NAME}-${EXT_VERSION}.tgz $EXT_URL
  if [ $? -eq 0 ]; then
    sudo tar -xzf ${EXT_NAME}-${EXT_VERSION}.tgz
    sudo rm ${EXT_NAME}-${EXT_VERSION}.tgz
  else
    echo "    Download failed"
    sudo rm ${EXT_NAME}-${EXT_VERSION}.tgz
    exit 1
  fi
fi

if [ -d "$EXT_SRC" ]; then

  cd "$EXT_SRC"
  sudo rm -f $LOGFILE

  echo "    phpize ..."
  sudo /opt/php/$PHP_VERSION/bin/phpize >>$LOGFILE 2>&1
  if [ ! $? -eq 0 ]; then
    echo "    ERROR: phpize failed"
    exit 2
  fi
  
  # Configure
  CONF_FLAGS=""
  if [ "$EXT_NAME" == "xdebug" ]; then
    CONF_FLAGS="--enable-xdebug"
  fi
  if [ "$EXT_NAME" == "imagick" ]; then
#    sudo ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin/MagickWand-config 2>/dev/null
#    sudo ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/Wand-config /usr/bin/Wand-config 2>/dev/null
    sudo ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16 /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin 2>/dev/null
    CONF_FLAGS="--with-imagick=/usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/"
  fi
  echo "    configure [$CONF_FLAGS] ..."
  sudo ./configure $CONF_FLAGS --with-php-config=/opt/php/$PHP_VERSION/bin/php-config >>$LOGFILE 2>&1
  if [ ! $? -eq 0 ]; then
    tail -n20 $LOGFILE
    echo "    ERROR: configure failed. Log: $LOGFILE"
    exit 2
  fi

  echo "    Compiling extension ..."
  sudo make clean >>$LOGFILE 2>&1
  sudo make >>$LOGFILE 2>&1
  if [ ! $? -eq 0 ]; then
    tail -n20 $LOGFILE
    echo "    ERROR: make failed. Log: $LOGFILE"
    exit 2
  else
    mkdir -p /vagrant/files/php/$PHP_VERSION/lib
    cp $EXT_SRC/modules/*.so /vagrant/files/php/$PHP_VERSION/lib
    sudo cp $EXT_SRC/modules/*.so `/opt/php/$PHP_VERSION/bin/php-config --extension-dir`/
    if [ $? -eq 0 ]; then
      echo "    Extension installed successfully. Don't forget to activate it."
    else
      tail -n20 $LOGFILE
      echo "    ERROR: install failed. Log: $LOGFILE"
      exit 3
    fi
    sudo make distclean >>$LOGFILE 2>&1
  fi
  #copy .so
fi
