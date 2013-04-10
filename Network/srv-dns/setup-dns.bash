#!/bin/bash

echo "install bind"
yum -y install  bind bind-libs bind-utils
 
echo "start service named at boot"
chkconfig named on
 
echo "start service"
service named start

echo "configure dns"

