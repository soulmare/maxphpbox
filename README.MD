# MaxPHPBox Vagrant
*Custom Vagrant configuration, based on widely used **bento/ubuntu-16.04** basebox, setting up a LAMP server with multiple PHP versions easy switchable for every virtual host.*

## Description

**MaxPHPBox Vagrant stills in maintenance state, though not fully automated and not well-documented yet**. For LAMP stack installation you first need to prepare all needed PHP .deb packages. To compile PHPs and package your own debs, you must invoke provisioners chain: *"install-build-tools,build-php,package-php"*. If this procedure succeeds, in host's *files/deb/* directory will be created ready-to-install deb packages for every PHP version. If later you'll decide to *vagrant destroy && vagrant up* your guest, there's no need to compile them again - they will be automatically installed from packages. Later, compiling process should be fully automated with no need to invoke any provisioners by hand.

## PHP versions included

* 7.0.30 (Apache module from Ubuntu 16.04 repository)
* 5.2.17 (CLI/CGI)
* 5.3.29 (CLI/CGI)
* 5.4.45 (CLI/CGI)
* 5.5.38 (CLI/CGI)
* 5.6.36 (CLI/CGI)
* 7.0.30 (CLI/CGI)
* 7.1.18 (CLI/CGI)
* 7.2.7 (CLI/CGI)

## PHP extensions included

* XDebug
* Memcached
* Imagick
* GD
* ... and others ...

## Other software included

* MySQL
* Sqlite
* MailHog
* Ruby
* Git
* Htop

## Configuration

**/etc/php.ini** is shared by all PHP versions.

**Virtual host** stores it's web files in *vhosts/<virtual_host_name>/public_html*. But also is processed *vhosts/<virtual_host_name>/.htaccess* file (located upper to web dir), where can be placed some development directives - for example, switching PHP version.

Listed **custom CLI/CGI PHPs will be compiled on guest machine** (thanks to [Phpbrew](https://github.com/phpbrew/phpbrew) tool) before installing as a part of LAMP stack. **Virtual hosts are created automatically** when you add a subdirectory in *vhosts/* (of course, you must also add them to */etc/hosts* to get them working). Virtual host web files are located on your host machine, and can be edited with any text editor or IDE. If on your environment it causes performance problems, try to change shared folder's type, or put your web files into guest's */var/www/* to receive all possible efficiency. Also changing *v.cpus* parameter in *Vagrantfile* may help. Databases are stored on guest's filesystem.

## Access from host to guest

root password: vagrant

user name: vagrant

user password: vagrant

ssh vagrant@192.168.50.2

ssh vagrant@vagrant

http://192.168.50.2/

http://vagrant/

mysql -uroot -proot -h 192.168.50.2

mysql -uroot -proot -h vagrant

## Install NFS daemon on Ubuntu host:

sudo apt-get install -y nfs-kernel-server nfs-common

## Install SSHFS shared folders support:

sudo apt-get install -y openssh-server
vagrant plugin install vagrant-sshfs
sudo ln -s /usr/lib/openssh/sftp-server /usr/bin/sftp-server

## MailHog
http://vagrant:8025/

## Mailcatcher
http://vagrant:1080/
