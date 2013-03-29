#!/bin/bash

echo "install ntp"
yum -y install ntp
echo "activate ntp on boot"
chkconfig ntpd on
echo "start ntp service"
service ntpd start
