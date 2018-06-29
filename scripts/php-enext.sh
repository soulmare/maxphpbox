#!/bin/bash

PHP_INST_FOLDERS=/opt/php/*

for PHP_INST in $PHP_INST_FOLDERS
do
	FILES=(`$PHP_INST/bin/php-config --extension-dir`/*.so)

	PHP_VER=`$PHP_INST/bin/php-config --version`
  a=( ${PHP_VER//./ } ) # replace points, split into array
  ((a[2]++)) # increment revision (or other part)
  PHP_VERSION_MAJOR="${a[0]}.${a[1]}" # shorten version

	echo "Enable PHP $PHP_VERSION_MAJOR extensions"
	sudo mkdir -p $PHP_INST/etc/php.d
#	echo ${FILES[@]}
  for FNAME in ${FILES[@]}
  do
    FNBASE=$(basename $FNAME)
    EXTNAME=${FNBASE%.*}
#    printf "$EXTNAME "
    EXT_INI=$PHP_INST/etc/php.d/20-$EXTNAME.ini
    if [ ! -f $EXT_INI ]; then
      if [ ! -f $EXT_INI-disabled ]; then
        if [[ "$EXTNAME" == "xdebug" || "$EXTNAME" == "opcache" ]]; then
          echo "zend_extension=$FNAME" | sudo tee $EXT_INI >/dev/null
        else
          echo "extension=$FNBASE" | sudo tee $EXT_INI >/dev/null
        fi
      else
        sudo mv $EXT_INI-disabled $EXT_INI
      fi
    fi
  done
#  echo ""
  /opt/php/$PHP_VERSION_MAJOR/bin/php -m > /vagrant/files/php/$PHP_VERSION_MAJOR/modules.txt 2>&1
  /opt/php/$PHP_VERSION_MAJOR/bin/php -i > /vagrant/files/php/$PHP_VERSION_MAJOR/phpinfo.txt 2>&1
done

# Disable mysqli because of a bug :(
sudo mv /opt/php/5.2/etc/php.d/20-mysqli.ini /opt/php/5.2/etc/php.d/20-mysqli.ini-disabled
