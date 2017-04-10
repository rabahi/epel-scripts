#!/bin/bash

echo "install dnf-automatic"
dnf -y install dnf-automatic

echo "enable 'apply_updates'"
sed -i "s/^\(apply_updates\s*=\s*\).*/\1yes/g" /etc/dnf/automatic.conf

echo "activate dnf-automatic at startup"
systemctl enable dnf-automatic.timer

echo "start service"
systemctl start dnf-automatic.timer

## OLD Package Manager
echo "install yum-cron"
dnf -y install yum-cron

echo "activate yum-cron at startup"
systemctl enable yum-cron.service

echo "start service"
systemctl start yum-cron.service
