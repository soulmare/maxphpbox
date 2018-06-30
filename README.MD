# MaxPHPBox Vagrant
*MaxPHPBox is Vagrant configuration, based on **bento/ubuntu-16.04** basebox image, which provides a ready to work LAMP stack with an ability to select PHP version for every virtual host. New virtual hosts are created by simply adding new directories into vhosts/ dir. Included script for easy backup/restore all MySQL databases of guest machine, so it can be painlessly recreated from scratch.*

#### Attention! On the first vagrant up will be built PHP packages from sources, that may consume a lot of time. Packages are saved in host directory, though are not deleted on future vagrant destroy, and future vagrant up's are lot faster than very first one.

## Description

**MaxPHPBox Vagrant** provides fully functional LAMP stack installation with multiple PHP versions, switchable for every virtual host.

### PHP versions included

* 7.0.30 (Apache module from Ubuntu 16.04 repository)
* 5.2.17 (CLI/CGI)
* 5.3.29 (CLI/CGI)
* 5.4.45 (CLI/CGI)
* 5.5.38 (CLI/CGI)
* 5.6.36 (CLI/CGI)
* 7.0.30 (CLI/CGI)
* 7.1.18 (CLI/CGI)
* 7.2.7 (CLI/CGI)

### PHP extensions included

* XDebug
* Memcached
* Imagick
* GD
* ...

### Other software included

* MySQL
* Sqlite
* Ruby
* Git
* Htop
* ack (grep tool for programmers)
* Webgrind (PHP profiling in the browser)
* MailHog (debug PHP emails)

## Configuration

**/etc/php.ini** is shared by all PHP versions.

**Virtual hosts'** web files are located in *vhosts/<virtual_host_name>/public_html*. Also *vhosts/<virtual_host_name>/.htaccess* file is processed (located one level up to web dir), where one can place some development directives - switching PHP version, etc.

Listed **custom CLI/CGI PHPs will be compiled on guest machine** (thanks to [Phpbrew](https://github.com/phpbrew/phpbrew) tool) before installing as a part of LAMP stack. Building all these PHPs on guest machine may consume a lot of time, though this approach may be changed in future versions to preloading ready-to-use PHP debs from somewhere.

**Virtual hosts are created automatically** when you add a subdirectory in *vhosts/* (of course, they must be added to */etc/hosts* to get them working in local web-browser). Placing virtual hosts' web files on your host machine's shared folder is comfortable for development, as then they can be edited locally with any text editor or IDE. Unfortunately, on some environments it may cause performance problems. If so, you may try changing shared folder's type, or putting your web files into guest's */var/www/* to reach all possible efficiency from large PHP applications. Also changing *v.cpus* parameter in *Vagrantfile* may help.

**MySQL databases** are stored on guest's filesystem, though they will be lost when the guest is destroyed. For creating host's local backup of all guest's MySQL databases is used *Percona Xtrabackup* utility, which deals with binary database files and is faster then traditional *mysqldump*. To backup databases, launch command *vagrant provision --provision-with backup-databases*, and when you next destroy and recreate your guest, this backup will be automatically imported on first boot.

### Install NFS daemon on Ubuntu host:

sudo apt-get install -y nfs-kernel-server nfs-common

### Install SSHFS shared folders support for your host:

sudo apt-get install -y openssh-server
vagrant plugin install vagrant-sshfs
sudo ln -s /usr/lib/openssh/sftp-server /usr/bin/sftp-server

### Access from host to guest

root password: vagrant

user name: vagrant

user password: vagrant

ssh vagrant@192.168.50.2

ssh vagrant@vagrant

#### HTTP

http://192.168.50.2/

http://vagrant/

#### MySQL

mysql -uroot -proot -h 192.168.50.2

mysql -uroot -proot -h vagrant

#### MailHog
http://vagrant:8025/

#### Mailcatcher

(if is installed instead of MailHog)

http://vagrant:1080/

## Contribution

If you like this project, you may want to contribute in some way:
* Fork, bugfix, impove & merge
* Bug report or maybe, feature request
* Documentation improve, spellchecking & english grammar, comments on source code, etc

For development needs can be used *./auto-snapshot.sh* script, which recreates a machine from scratch and saves a snapshot after each successfull provisioner. 
