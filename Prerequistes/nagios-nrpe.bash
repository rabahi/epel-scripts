#!/bin/bash

echo "install nrpe"
yum -y install nrpe nagios-plugins-all

echo "start nrpe on boot"
systemctl enable nrpe.service

echo "add service nrpe (port 5666) to firewall"
firewall-cmd --permanent --zone=public --add-port=5666/tcp

echo "sudoers configuration (deal with issue 'NRPE: Unable to read output')"
chmod 755 /etc/sudoers
sed -i "s/^\(Defaults\s*requiretty\)/#\1/" /etc/sudoers
chmod 0440 /etc/sudoers

echo "allow every one to connect to nrpe"
sed -i "s/^\(allowed_hosts\)/#\1/" /etc/nagios/nrpe.cfg
  
echo "start nrpe"
systemctl start nrpe.service
