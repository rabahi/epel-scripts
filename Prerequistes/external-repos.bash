#!/bin/bash

echo "get release rpm from fedora"
rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm

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
yum -y update
