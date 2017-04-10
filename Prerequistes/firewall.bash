#!/bin/bash

echo "install firewalld"
dnf -y install firewalld

echo "activate firewalld at startup"
systemctl enable firewalld.service

echo "start service"
systemctl start firewalld.service
