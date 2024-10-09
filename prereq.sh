#!/bin/bash

########################################
### USING PROXY SETTINGS
### If EC2 is behind a proxy use the following commands
### Replace place holder with Proxy IP
### NOTE that the HTTPS env var also has http://, using https:// caused issues during my testing
#export HTTP_PROXY="http://II.III.III.II:80" 
#export HTTPS_PROXY="http://II.III.III.II:80"
#export http_PROXY="http://II.III.III.II:80" 
#export https_PROXY="http://II.III.III.II:80"
### NOTE If running behind a proxy and as ec2-user any pip installs will need to have the -E option...
### as in the following example
#sudo -E pip3 install s3transfer botocore boto3
########################################

########################################
### The following items need to be installed
### Ansible aws modules and botocore/boto3 play nice with python3.6
### There are workarounds to make the script work with other python versions
### For simplicity I will just include the python3.6 related packages
### The following is a list of packages and versions used during creation/testing/implementation of the script
########################################

sudo dnf install -q -y wget curl vim python3.11 python3.11-pip unzip net-tools bind-utils parted gdisk
sudo pip3.11 --version
sudo pip3.11 install ansible s3transfer botocore boto3
sudo ansible --version
### If using newly created directory cd to that location for aws installation
### cd /ec2-ansible
curl -k 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
sudo unzip -q awscliv2.zip
sudo ./aws/install
aws --version



