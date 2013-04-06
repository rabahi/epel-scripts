#!/bin/bash

echo "install nrpe"
yum -y install nrpe nagios-plugins*

echo "start nrpe on boot"
chkconfig nrpe on

echo "open nrpe port"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 5666 -j ACCEPT
service iptables save
service iptables restart

echo "sudoers configuration (deal with issue 'NRPE: Unable to read output')"
chmod 755 /etc/sudoers
sed -i "s/^\(Defaults\s*requiretty\)/#\1/" /etc/sudoers
chmod 0440 /etc/sudoers

echo "allow every one to connect to nrpe"
sed -i "s/^\(allowed_hosts\)/#\1/" /etc/nagios/nrpe.cfg
  
echo "start nrpe"
service nrpe start