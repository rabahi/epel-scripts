#!/bin/bash

echo "get release rpm from fedora"
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

echo "add sourceforge repository"
rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

echo "add webmin repository"
echo > /etc/yum.repos.d/webmin.repo << "EOF"
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
EOF
rpm --import http://www.webmin.com/jcameron-key.asc