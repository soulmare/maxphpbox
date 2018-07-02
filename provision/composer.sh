#!/bin/bash

# Install Composer

source /vagrant/scripts/setvars.sh

# Test if Composer is installed
#composer -v > /dev/null 2>&1
#COMPOSER_IS_INSTALLED=$?
#
#if [[ $COMPOSER_IS_INSTALLED -ne 0 ]]; then
#  echo "${TXHLT}Install Composer${TXNORM}"
#  curl -sS https://getcomposer.org/installer | php
#  sudo mv composer.phar /usr/local/bin/composer
#else
#  echo "Self-update Composer"
#  composer self-update
#fi

# Install Global Composer Packages if any are given

COMPOSER_PACKAGES=$1
if [[ ! -z $COMPOSER_PACKAGES ]]; then
    echo "${TXHLT}Install Global Composer Packages${TXNORM}"
    echo "    " ${COMPOSER_PACKAGES[@]}
    
    # Add Composer's Global Bin to ~/.profile path
    if [[ -f "/home/vagrant/.profile" ]]; then
        if ! grep -qsc 'COMPOSER_HOME=' /home/vagrant/.profile; then
            # Ensure COMPOSER_HOME variable is set. This isn't set by Composer automatically
            printf "\n\nCOMPOSER_HOME=\"/home/vagrant/.composer\"" >> /home/vagrant/.profile
            # Add composer home vendor bin dir to PATH to run globally installed executables
            printf "\n# Add Composer Global Bin to PATH\n%s" 'export PATH=$PATH:$COMPOSER_HOME/vendor/bin' >> /home/vagrant/.profile
            # Source the .profile to pick up changes
            . /home/vagrant/.profile
        fi
    fi
    
    composer global require ${COMPOSER_PACKAGES[@]}
fi
