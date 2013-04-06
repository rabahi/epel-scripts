#!/bin/bash
 
echo "install tools nagios"
yum -y install nagios nagios-devel nagios-plugins*

echo "enable start nagios on boot"
chkconfig nagios on
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/nagios/"
echo "Note, login/passord is nagiosadmin/nagiosadmin"
