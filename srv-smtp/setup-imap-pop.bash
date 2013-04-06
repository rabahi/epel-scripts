#!/bin/bash

echo "install dovecot"
yum -y install dovecot

echo "configure dovecot"
sed -i "s/^#\(protocols\s*=\)/\1/" /etc/dovecot/dovecot.conf
 
echo "start service"
service dovecot start


echo "open smtp port (i.e 25)"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 25 -j ACCEPT
service iptables save
service iptables restart
