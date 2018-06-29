root password: vagrant
user name: vagrant
user password: vagrant

#Install NFS daemon on Ubuntu host:
#sudo apt-get install -y nfs-kernel-server nfs-common

# To make available SSHFS shared folders:
#sudo apt-get install -y openssh-server
vagrant plugin install vagrant-sshfs
sudo ln -s /usr/lib/openssh/sftp-server /usr/bin/sftp-server

ssh vagrant@192.168.50.2
http://192.168.50.2/
mysql -uroot -proot -h 192.168.50.2

  Through forwarded ports, if enabled:
  
http://127.0.0.1:8080/
ssh vagrant@127.0.0.1 -p 2222
mysql -uroot -proot -h 127.0.0.1 -P 3360

  Mailcatcher
http://vagrant:1080/

  MailHog
http://vagrant:8025/
