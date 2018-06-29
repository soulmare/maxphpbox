# MaxPHPBox Vagrant
*Vagrant configuration based on **bento/ubuntu-16.04** basebox image. LAMP stack with ability to select PHP version for every virtual host. Automatic virtual hosts creation by simply creating new directories. Automatic backup/restore MySQL databases. No custom binaries, all is made mostly with Vagrant's shell provisioners.*

### Attention! On first vagrant up it will build multiple PHP packages from sources, it may consume a lot of time.

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

**Virtual hosts'** web files are located in *vhosts/<virtual_host_name>/public_html*. Also *vhosts/<virtual_host_name>/.htaccess* file is processed (located one level up to web dir), where one can place some development directives - switching PHP version, etc.

Listed **custom CLI/CGI PHPs will be compiled on guest machine** (thanks to [Phpbrew](https://github.com/phpbrew/phpbrew) tool) before installing as a part of LAMP stack. Building all these PHPs on guest machine may consume a lot of time, though this approach may be changed in future versions to preloading ready-to-use PHP debs from somewhere.

**Virtual hosts are created automatically** when you add a subdirectory in *vhosts/* (of course, they must be added to */etc/hosts* to get them working in local web-browser). Placing virtual hosts' web files on your host machine's shared folder is comfortable for development, as then they can be edited locally with any text editor or IDE. Unfortunately, on some environments it may cause performance problems. If so, you may try changing shared folder's type, or putting your web files into guest's */var/www/* to reach all possible efficiency from large PHP applications. Also changing *v.cpus* parameter in *Vagrantfile* may help.

**MySQL databases** are stored on guest's filesystem, though they will be lost when the guest is destroyed. For creating host's local backup of all guest's MySQL databases is used *Percona Xtrabackup* utility, which deals with binary database files and is faster then traditional *mysqldump*. To backup databases, launch command *vagrant provision --provision-with backup-databases*, and when you next destroy and recreate your guest, this backup will be automatically imported on first boot. 

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
