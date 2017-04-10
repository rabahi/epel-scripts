#!/bin/bash

echo "get release rpm from fedora"
dnf -y install epel-release

#echo "enable Red Hat Software Collections (SCL) repository"
#dnf -y install centos-release-scl

echo "add webmin repository"
cat > /etc/dnf.repos.d/webmin.repo << "EOF"
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/dnf
mirrorlist=http://download.webmin.com/download/dnf/mirrorlist
enabled=1
EOF
rpm --import http://www.webmin.com/jcameron-key.asc

echo "clean all and update"
dnf clean all
dnf -y install deltarpm
dnf -y update
