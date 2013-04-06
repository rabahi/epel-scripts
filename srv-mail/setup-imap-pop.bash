#!/bin/bash

echo "install dovecot"
yum -y install dovecot

echo "configure dovecot"
sed -i "s/^#\(protocols\s*=\)/\1/" /etc/dovecot/dovecot.conf
 
echo "start service"
service dovecot start


echo "open pop3 port (i.e 110) and imap (i.e. 143)"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 110 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 143 -j ACCEPT
service iptables save
service iptables restart
