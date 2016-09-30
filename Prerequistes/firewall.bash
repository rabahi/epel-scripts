#!/bin/bash

echo "install firewalld"
yum -y install firewalld

echo "activate firewalld at startup"
systemctl enable firewalld.service

echo "start service"
systemctl start firewalld.service
