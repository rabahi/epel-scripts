#!/bin/bash

echo "install nrpe"
yum -y install nrpe

echo "start nrpe on boot"
chkconfig nrpe on

echo "open nrpe port"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 5666 -j ACCEPT
service iptables save
service iptables restart

echo "start nrpe"
service nrpe start