# rhel9-disastig-partition

Ansible script for performing DISA STIG partitioning on an AWS EC2 instance without reboot

# Enterprise Image RHEL 9

## Overview

This repo runs an Ansible playbook that will do the following:

* Increase the ec2 root/boot volume size
* Move backup GPT data structures to the end of the disk
* Creates new partitions in accordance with DISA STIG requirments
* Update partition table without rebooting the server
* Syncs files/dirs of directories to /mnt
* Mounts new partitions, creates the files systems and syncs content back into correct location
* Updates the /etc/fstab

## Usage

### PreReqs

#### In order for the script to work properly a few pre-requirements must be done to the server.

Please see prereq.sh for more information

#### Extra Vars

The following are the extra vars that can be passed to the ansible playbook:

```txt
Extra vars that can be passed to the script
--extra-vars "vol_new_size": Size to modify ec2 volume to. 
  Default value is 60. 
  (NOTE: If starting vol size is 10 and this var is set to 50 
   the final vol size will be 50)
--extra-vars "boot_size": Size of the partion for /boot
  Default value is 1G
--extra-vars "var_size": Size of the partion for /var
  Default value is 15
--extra-vars "log_size"
  Default value is 7
--extra-vars "vtmp_size"
  Default value is 2
--extra-vars "audit_size"
  Default value is 5
--extra-vars "home_size"
  Default value is 7
--extra-vars "tmp_size"
  Default value is 3

  
```

Note:

    - The script will determine the device naming of the EC2 volume, the default is /dev/xvda but the script will also work with /dev/nvme... types. There is a Ansible pretask that will check the device name and set partition naming based on this.

    - The defaults set in the Ansible script were the partition sizes recommended for a simple server. These sizes can/should be adjusted based on individual's requirements/needs

    - The starting size of the EC2 volume during testing was 10G and the default value for volume modification was 50G (increase of 40G). Both of these values can be increased depending on individual's requirements/needs. The starting size (10G) would need to be set during EC2 creation, the increase size can be passed as an extra-var.

#### Ansible Gotcha

When running an Ansible playbook Ansible will create a .ansible directory in the /home dir of the user running the ansible cli. In most cases ansible playbooks are run as a specific user (during development the playbook was run by ec2-user). Since there is a task that creates a partition and new mount for /home dir any ansible playbooks being run by said user will lose access to the .ansible dir that was created on initial launch of the playbook. This will cause the playbook to fail.

In order to prevent this issue the playbook must be launched by root or using sudo in front of the ansible command.

```bash
#Run ansible using sudo
sudo ansible-playbook ec2-partitions.yml
#Run ansible as root
sudo su -
ansible-playbook /path/to/playbook/ec2-partitions.yml
```

For convenience and easy cleanup a directory was created at / to store the ansible code. This directory can be removed after the partitioning is complete if necessary.

```bash
sudo mkdir /ec2-ansible
sudo chown ec2-user:ec2-user /ec2-ansible
sudo chmod 775 /ec2-ansible
```

#### AWS Gotcha

The script uses aws cli commands and ansible amazon.aws modules. As such the instance must have either an AWS profile/AWS credentials that grant the appropriate permissions for EC2/Volume manipulation. The profile/credentials can be included as an env variable on the server, included with an attached IAM role etc.

## Process

### Requirements

* An AWS account with appropriate permissions/access
* Packages:
  * python (3.11.2)
  * pip (22.3.1)
  * wget (1.19.5-11.el8)
  * curl (7.61.1-30.el8_8.2)
  * unzip (6.0-46.el8)
  * net-tools (2.0-0.52.20160912git.el8)
  * bind-utils (32:9.11.36-8.el8_8.1)
  * parted (3.2-39.el8)
  * gdisk (1.0.3-11.el8)
  * ansible-core (2.14.2)
  * jinja (3.1.2)
  * awscli (2.13.8)
  * s3transfer (0.6.1)
  * botocore (1.31.23)
  * boto3 (1.28.23)
  * jmespath (1.0.1)
  * urllib3 (1.26.16)

### AWS EC2

* Launch an EC2 instance from preferred RHEL8 AMI.
* Ensure the starting root volume is set as desired
* Using whichever method preferred (GitLab CI/CD, Packer, CloudFormation, AWS System Manager etc) clone/put the Ansible code on the newly launched server

### Usage

Correct use of this Ansible playbook will result in an AWS EC2 instance with the following partitions (using /dev/xvda in example)

```bash
NAME        MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda     259:0    0  50G  0 disk
├─xvda1 259:1    0   1M  0 part
├─xvdap2 259:2    0  10G  0 part /
├─xvdap3 259:3    0  10G  0 part /var
├─xvdap4 259:4    0   5G  0 part /var/log
├─xvdap5 259:5    0   2G  0 part /var/tmp
├─xvdap6 259:6    0   5G  0 part /var/log/audit
├─xvdap7 259:7    0   5G  0 part /home
└─xvdap8 259:8    0   3G  0 part /tmp
```

### Partitioning Process

1. Launch EC2 instance
2. Use preferred method to install pre-req packages on EC2
3. Clone/Sync this repo onto instance
4. Run Ansible playbook command and include any extra-vars necessary to overwrite default values

   ```
   cd /path/to/ansible/playbook/
   sudo ansible-playbook ec2-partitions.yml
   ```
5. Once script has completed successfully an AMI can be created using the EC2 instance. This will ensure any EC2s launched from the newly created AMI has the correct partitions.

### License and Author

* Author :: Antonio Monteze Hayes Punzo
