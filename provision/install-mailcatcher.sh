#!/bin/bash

# Install Mailcatcher

if ! which mailcatcher>/dev/null; then

  echo "$Install Mailcatcher ..."
  
  apt-get install -yq g++ ruby ruby-dev libsqlite3-dev
  
  gem install --no-rdoc --no-ri mailcatcher
  
  # Make it start on boot

  tee /etc/systemd/system/mailcatcher.service <<EOL
[Unit]
Description=MailCatcher service

[Service]
ExecStart=/usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0

[Install]
WantedBy=multi-user.target
EOL

  #ExecStart=$(which mailcatcher)
  #ExecStart=/usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0
    
  systemctl enable mailcatcher
  
  # Start Mailcatcher now  
  systemctl start mailcatcher
  
  # Forward PHP mail to MailCatcher
  printf "\n# Forward PHP mail to MailCatcher\nsendmail_path = /usr/bin/env catchmail -f vagrant@vagrant\n" >>/etc/php.ini    
  
  echo "Restart Apache ..."
  service apache2 restart

else

  echo "MailCatcher already installed"
  
fi
