#!/bin/bash

echo "install yum-cron"
yum -y install yum-cron

echo "activate yum-cron at startup"
chkconfig yum-cron on

echo "start service"
service yum-cron start
