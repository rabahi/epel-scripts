#!/bin/bash

echo "install dnf-cron"
dnf -y install dnf-cron

echo "activate dnf-cron at startup"
systemctl enable dnf-cron.service

echo "start service"
systemctl start dnf-cron.service
