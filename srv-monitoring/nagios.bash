#!/bin/bash
 
echo "install tools nagios"
yum -y install nagios nagios-devel nagios-plugins*

echo "enable start nagios on boot"
chkconfig nagios on
 
echo "check_http get a 403 'forbidden' if index.html is missing. so we create it"
touch /var/www/html/index.html
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/nagios/"
echo "Note, login/passord is nagiosadmin/nagiosadmin"
