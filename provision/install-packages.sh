#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

source /vagrant/scripts/setvars.sh

if [ ! -f /root/.bash_aliases ]; then
  cp /vagrant/files/configs/bash_aliases /root/.bash_aliases
fi

if [ ! -f /home/vagrant/.bash_aliases ]; then
  cp /vagrant/files/configs/bash_aliases /home/vagrant/.bash_aliases
  chown vagrant:vagrant /home/vagrant/.bash_aliases
fi

echo "${FBOLD}Update apps ...${FNORM}"
apt-get update -q && apt-get upgrade -yq

SYSTEM_PACKAGES=$1
if [[ ! -z $SYSTEM_PACKAGES ]]; then
#  echo "${FBOLD}Install system packages${FNORM}"
  #echo "    " ${SYSTEM_PACKAGES[@]}
  for PACKAGE in $SYSTEM_PACKAGES
  do
    if ! command -v $PACKAGE >/dev/null; then
      echo "${FBOLD}Install $PACKAGE ...${FNORM}"
      apt-get install -yq $PACKAGE
    fi
  done
fi
