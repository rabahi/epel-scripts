#!/bin/bash

echo "install locate"
yum -y install mlocate
updatedb

echo "install wget"
yum -y install wget

echo "install dos2unix"
yum -y install dos2unix

echo "install telnet client"
yum -y install telnet
