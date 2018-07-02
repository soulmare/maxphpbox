# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-16.04"
  config.vm.box_check_update = false

  # Override host locale
  ENV['LC_ALL']="en_US.UTF-8"

  # Machine settings

  config.vm.provider "virtualbox" do |v|
    v.name = "maxphpbox"
    #v.cpus = 2
    #v.memory = 512
    v.cpus = 4
    v.memory = 2048
  end
  
  # to use half of available CPUs
  #config.vm.customize ["modifyvm", :id, "--cpus", `awk "/^processor/ {++n} END {print n}" /proc/cpuinfo 2> /dev/null || sh -c 'sysctl hw.logicalcpu 2> /dev/null || echo ": 2"' | awk \'{print \$2}\' `.chomp ]

  # Reverse mounted share
  #config.vm.synced_folder "etc", "/etc", type: 'sshfs', reverse: true
  #config.vm.synced_folder "log", "/var/log", type: 'sshfs', reverse: true

  #config.vm.synced_folder 'etc', '/etc', type: 'nfs_guest', mount_options: ["rw"]
  #config.vm.synced_folder 'log', '/var/log', type: 'nfs_guest'

  #config.vm.synced_folder "vhosts", "/vhosts", owner: "www-data", group: "www-data"
  config.vm.synced_folder "vhosts", "/vhosts", type: "nfs"
  #config.vm.synced_folder "vhosts", "/vhosts", type: "nfs", nfs_version: 4, nfs_udp: false
  #config.vm.synced_folder "vhosts", "/vhosts", type: "sshfs"

  #config.vm.synced_folder "vhosts", "/vhosts", mount_options: ["uid=10005,gid=1005"]
  #config.vm.provision :shell do |shell|
  #  shell.inline = "groupadd -g 1005 www-data &2>/dev/null;
  #                  useradd -c 'Apache www-data User' -d /home/www-data -g www-data -m -u 10005 www-data &2>/dev/null;"
  #end
  
  # Network

  config.vm.network "private_network", ip: "192.168.50.2"
  
  # Web server
  #config.vm.network "forwarded_port", guest: 80, host: 8080

  # MySQL server
  #config.vm.network "forwarded_port", guest: 3306, host: 3360

  composer_packages     = [        # List any global Composer packages that you want to install
    "phpunit/phpunit:6.0.*",
    #"codeception/codeception=*",
    #"phpspec/phpspec:2.0.*@dev",
    #"squizlabs/php_codesniffer:1.5.*",
  ]

  # Provisioners

  config.vm.provision "install-apps",
    type: "shell",
    path: "provision/install-apps.sh"

  config.vm.provision "build-php",
    type: "shell",
    keep_color: true,
    path: "provision/build-php.sh"

  config.vm.provision "package-php",
    type: "shell",
    keep_color: true,
    path: "provision/package-php.sh"

  config.vm.provision "lamp-setup",
    type: "shell",
    path: "provision/lamp-setup.sh"

  config.vm.provision "composer",
    type: "shell",
    privileged: false,
    args: [composer_packages.join(" ")],
    path: "provision/composer.sh"

  config.vm.provision "install-mailhog",
    type: "shell",
    path: "provision/install-mailhog.sh"

  # MailCatcher can be installed instead of MailHog
  #config.vm.provision "install-mailcatcher",
  #  type: "shell",
  #  path: "provision/install-mailcatcher.sh"

  config.vm.provision "restore-databases",
    type: "shell",
    keep_color: true,
    run: "always",
    path: "provision/restore-databases.sh"

  config.vm.provision "vhosts",
    type: "shell",
    run: "always",
    path: "provision/vhosts.sh"


  # Special non-automatic provisiners

  config.vm.provision "backup-databases",
    type: "shell",
    keep_color: true,
    run: "never",
    path: "provision/backup-databases.sh"

  config.vm.provision "purge-build-stuff",
    type: "shell",
    run: "never",
    path: "provision/purge-build-stuff.sh"


end
