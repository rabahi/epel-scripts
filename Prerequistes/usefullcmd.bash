#!/bin/bash

echo "install ifconfig"
dnf -y install net-tools

echo "install locate"
dnf -y install mlocate
updatedb

echo "install wget"
dnf -y install wget

echo "install dos2unix"
dnf -y install dos2unix

echo "install telnet client"
dnf -y install telnet

echo "install zip tools"
dnf -y install zip unzip
