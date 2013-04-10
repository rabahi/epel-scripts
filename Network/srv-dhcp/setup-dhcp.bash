#!/bin/bash

echo "install dhcp"
yum -y install dhcp
 
echo "start service dhcpd at boot"
chkconfig dhcpd on
 
echo "start service"
service dhcpd start

echo "configure dhcp"

