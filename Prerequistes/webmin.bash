#!/bin/bash

echo "install webmin"
yum -y install webmin

echo "open port 10000"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 10000 -j ACCEPT
service iptables save
service iptables restart

echo "launch webmin"
service webmin start

echo "launch webmin on boot"
chkconfig webmin on