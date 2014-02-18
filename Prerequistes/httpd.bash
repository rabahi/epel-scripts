#!/bin/bash

########################
#### Install apache ####
########################

echo "install httpd"
yum -y install httpd

echo "activate httpd at startup"
chkconfig httpd on

echo "start service"
service httpd start


########################
#### FIREWALL RULES ####
########################

echo "Append rule to open port 80"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT

echo "Save rule"
service iptables save

echo "Now activate new rule."
service iptables restart
