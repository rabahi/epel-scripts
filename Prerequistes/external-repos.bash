#!/bin/bash

echo "get release rpm from fedora"
yum -y install epel-release

#echo "enable Red Hat Software Collections (SCL) repository"
#yum -y install centos-release-scl

echo "clean all and update"
yum clean all
yum -y install deltarpm
yum -y update
