#!/bin/bash
 
echo "get release rpm from fedora"
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
 
echo "install mock"
yum -y install mock
 
echo "only user who belongs to the group 'mock' can use mock. We add the user 'builder' to the mock group"
echo " 1. create user builder"
useradd builder
echo " 2. unlock builder account (that will create /home/builder directory)."
echo "set login/passwd : builder/builder"
echo builder | passwd builder --stdin
echo " 3. Add builder to the group 'mock'"
usermod -G mock -a builder

echo "Now create mock for centos 6 x64"
runuser -l builder -c 'mock -r epel-6-x86_64 --init'
runuser -l builder -c 'mock -r epel-6-x86_64 chroot "cat /etc/issue"'

