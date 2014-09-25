#!/bin/sh

# convert into Oracle Linux 6
curl -O https://linux.oracle.com/switch/centos2ol.sh
sh centos2ol.sh
yum upgrade -y

# fix locale warning
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

cd /etc/yum.repos.d
ls -al
sudo wget http://public-yum.oracle.com/public-yum-ol6.repo
sudo sed -i 's/enabled=0/enabled=1/' public-yum-ol6.repo

# install Oracle Database prereq packages
yum install -y oracle-rdbms-server-11gR2-preinstall

# install UEK kernel
yum install -y elfutils-libs
yum update -y --enablerepo=ol6_UEKR3_latest
yum install -y kernel-uek-devel --enablerepo=ol6_UEKR3_latest
grubby --set-default=/boot/vmlinuz-3.8*

# create directories
mkdir /opt/oracle /opt/oraInventory /opt/datafile \
 && chown oracle:oinstall -R /opt

sudo su - oracle

# set environment variables
echo "export ORACLE_BASE=/opt/oracle" >> /home/oracle/.bash_profile \
 && echo "export ORACLE_HOME=/opt/oracle/product/11.2.0/dbhome_1" >> /home/oracle/.bash_profile \
 && echo "export ORACLE_SID=orcl" >> /home/oracle/.bash_profile \
 && echo "export PATH=\$PATH:\$ORACLE_HOME/bin" >> /home/oracle/.bash_profile

# confirm
cat /etc/oracle-release