#!/bin/bash

echo "install ntp"
yum -y install ntp

echo "activate ntp on boot"
systemctl enable ntpd.service

echo "start ntp service"
systemctl start ntpd.service
