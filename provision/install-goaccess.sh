#!/usr/bin/env bash

# Install GoAccess Apache log analyser
# Usage:
#    goaccess /var/log/apache2/access.log --log-format=COMBINED
#    goaccess --log-format='%v %h %^[%d:%t %^] "%r" %s %b %D "%R" "%u"' --date-format=%d/%b/%Y --time-format=%T /vhosts/test.local/access_log

echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
sudo apt-get update -y
apt-get install goaccess -yq

# Install from source
#cd /usr/local/src/
#wget -q https://tar.goaccess.io/goaccess-1.2.tar.gz
#tar -xzf goaccess-1.2.tar.gz
#rm goaccess-1.2.tar.gz 
#cd goaccess-1.2/
#sudo apt-get install -yq libgeoip-dev libncursesw5-dev
#./configure --enable-utf8 --enable-geoip=legacy
#make
#make install
#ln -s /usr/local/bin/goaccess /usr/bin/goaccess

