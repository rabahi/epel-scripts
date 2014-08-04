#!/bin/bash

echo "install yum-cron"
yum -y install yum-cron

echo "activate yum-cron at startup"
systemctl enable yum-cron.service

echo "start service"
systemctl start yum-cron.service
