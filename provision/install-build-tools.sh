#!/bin/bash

#
# Prepare for building PHP and it's extensions
# This script must be invoked only if you need to (re-)build PHP yourself (it may take a lot of time).
#
#

export DEBIAN_FRONTEND=noninteractive

FBOLD=`tput bold`
FNORM=`tput sgr0`

