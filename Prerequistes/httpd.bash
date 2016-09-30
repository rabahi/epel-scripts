#!/bin/bash

########################
#### Install apache ####
########################

echo "install httpd"
yum -y install httpd

echo "activate httpd at startup"
systemctl enable httpd.service

echo "start service"
systemctl start httpd.service


########################
#### FIREWALL RULES ####
########################

echo "add service http (port 80) to firewall"
firewall-cmd --permanent --add-service http
firewall-cmd --reload
