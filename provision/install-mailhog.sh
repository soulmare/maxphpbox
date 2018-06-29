#!/bin/bash

source /vagrant/scripts/setvars.sh

if ! which mailhog>/dev/null; then

#  if ! which sendmail>/dev/null; then
#    echo "Install Sendmail"
#    apt-get install -yq sendmail
#  fi

  echo "Install MailHog"
#set -o xtrace

  if [ ! -f /vagrant/files/apps/mailhog ]; then
    echo "    Download MailHog ..."
    wget -q -O /vagrant/files/apps/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
  fi
  cp /vagrant/files/apps/mailhog /usr/local/bin/mailhog
  chmod +x /usr/local/bin/mailhog
  tee /etc/systemd/system/mailhog.service <<EOL
[Unit]
Description=MailHog Service
After=network.service vagrant.mount
[Service]
Type=simple
ExecStart=/usr/bin/env /usr/local/bin/mailhog > /var/log/mailhog.log 2>&1 &
[Install]
WantedBy=multi-user.target
EOL
  
  # Start on reboot
  systemctl enable mailhog
  
  # Start background service now
  systemctl start mailhog

  if ! which go>/dev/null; then
    echo "Install Go language"
    cd /root/
    if [ ! -f /vagrant/files/apps/go1.6.linux-amd64.tar.gz ]; then
      echo "    Download Go ..."
      wget -q -O /vagrant/files/apps/go1.6.linux-amd64.tar.gz /usr/local/bin/go https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
    fi
    tar -xzf /vagrant/files/apps/go1.6.linux-amd64.tar.gz -C /usr/local/
    chmod +x /usr/local/go/bin/*
    mkdir /usr/local/go-work
    export GOPATH=/usr/local/go-work
    export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
  fi

  if ! which mhsendmail>/dev/null; then
    echo "Install mhsendmail"
    go get github.com/mailhog/mhsendmail
    ln -s /usr/local/go-work/bin/mhsendmail /usr/local/bin/mhsendmail
  fi
  
  # Forward PHP mail to MailHog
  printf "\n# Forward PHP mail to MailHog\nsendmail_path = mhsendmail\n" >>/etc/php.ini    

  echo "Restart Apache ..."
  service apache2 restart
  
  # Check URL: http://vagrant:8025/

else

  echo "MailHog already installed"
  
fi
