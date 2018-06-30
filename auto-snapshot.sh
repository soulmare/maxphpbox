#!/bin/bash

# Recreate machine if exists, start new from scratch, save snapshot after each provisioner succeeds.
# Write output to vagrant.log and display on stdout

vagrant destroy
rm -f vagrant.log
vagrant up --no-provision 2>&1 | tee -a vagrant.log && \
    vagrant provision --provision-with install-apps 2>&1 | tee -a vagrant.log && \
    vagrant snapshot save 1-install-apps 2>&1 | tee -a vagrant.log && \
    vagrant provision --provision-with build-php 2>&1 | tee -a vagrant.log && \
    vagrant snapshot save 2-build-php 2>&1 | tee -a vagrant.log && \
    vagrant provision --provision-with package-php 2>&1 | tee -a vagrant.log && \
    vagrant snapshot save 3-package-php 2>&1 | tee -a vagrant.log && \
    vagrant provision --provision-with lamp-setup 2>&1 | tee -a vagrant.log && \
    vagrant snapshot save 4-lamp-setup 2>&1 | tee -a vagrant.log && \
    vagrant provision --provision-with install-mailhog 2>&1 | tee -a vagrant.log && \
    vagrant snapshot save 5-install-mailhog 2>&1 | tee -a vagrant.log && \
    vagrant provision --provision-with restore-databases 2>&1 | tee -a vagrant.log && \
    vagrant provision --provision-with vhosts 2>&1 | tee -a vagrant.log
    vagrant snapshot save 6-final 2>&1 | tee -a vagrant.log
