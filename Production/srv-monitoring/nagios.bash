#!/bin/bash
 
echo "install tools nagios"
dnf -y install nagios nagios-devel nagios-plugins*

echo "enable start nagios on boot"
systemctl enable nagios.service

echo "set config owner"
chown nagios:nagios /etc/nagios/ -R
service nagios reload

echo "check_http get a 403 'forbidden' if index.html is missing. so we create it"
touch /var/www/html/index.html
 
myip=`hostname -I`
echo "Now meet you here: http://$myip/nagios/"
echo "Note, login/passord is nagiosadmin/nagiosadmin"
