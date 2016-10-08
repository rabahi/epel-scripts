#!/bin/bash

########################
#### Install apache ####
########################

echo "install httpd"
yum -y install httpd mod_ssl

echo "activate httpd at startup"
systemctl enable httpd.service

echo "start service"
systemctl start httpd.service


########################
#### FIREWALL RULES ####
########################

echo "add service http (port 80) to firewall"
firewall-cmd --permanent --add-service http

echo "add service http (port 443) to firewall"
firewall-cmd --permanent --add-service https

firewall-cmd --reload
