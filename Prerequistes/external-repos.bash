#!/bin/bash

echo "get release rpm from fedora"
yum -y install epel-release

#echo "enable Red Hat Software Collections (SCL) repository"
#yum -y install centos-release-scl

echo "add webmin repository"
cat > /etc/yum.repos.d/webmin.repo << "EOF"
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
EOF
rpm --import http://www.webmin.com/jcameron-key.asc

echo "clean all and update"
yum clean all
yum -y install deltarpm
yum -y update
