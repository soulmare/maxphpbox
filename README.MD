# MaxPHPBox Vagrant
**Custom Vagrantbox based on common box *bento/ubuntu-16.04*, providing LAMP server with multiple PHP versions easy switchable for every virtual host.**

## PHP versions included:

* 7.0.30 (Apache module from Ubuntu 16.04 repository)
* 5.2.17 (CLI/CGI)
* 5.3.29 (CLI/CGI)
* 5.4.45 (CLI/CGI)
* 5.5.38 (CLI/CGI)
* 5.6.36 (CLI/CGI)
* 7.0.30 (CLI/CGI)
* 7.1.18 (CLI/CGI)
* 7.2.7 (CLI/CGI)

Listed **custom CLI/CGI PHPs will be compiled on guest machine** (thanks to [Phpbrew](https://github.com/phpbrew/phpbrew) util) before installing as a part of LAMP stack. **Virtual hosts are created automatically** when you add a subdirectory in *vhosts/*. Virtual host web files are located on your host machine, and can be edited with any text editor or IDE. Also, you can put your web files into guest's */var/www/* to increase performance. Databases are stored on guest's filesystem.

**Project is in maintenance state, is not fully automated** and not well-documented. For automatic installation you need to have compiled PHPs, packed in .deb files. To compile PHPs you must manually use the following provisioners chain: "install-build-tools,build-php,package-php". If this procedure succeeds, you will have in your host's *files/deb/* directory a ready-to-install packages for every PHP version, and if you'll decide to *vagrant destroy && vagrant up*, there's no need to compile them again. In future, it should be fully automated with no need to call any provisioners by hand.

## Access from host to guest

root password: vagrant

user name: vagrant

user password: vagrant

ssh vagrant@192.168.50.2

http://192.168.50.2/

mysql -uroot -proot -h 192.168.50.2

## Install NFS daemon on Ubuntu host:

sudo apt-get install -y nfs-kernel-server nfs-common

## To make available SSHFS shared folders:

sudo apt-get install -y openssh-server
vagrant plugin install vagrant-sshfs
sudo ln -s /usr/lib/openssh/sftp-server /usr/bin/sftp-server

## MailHog
http://vagrant:8025/

## Mailcatcher
http://vagrant:1080/
