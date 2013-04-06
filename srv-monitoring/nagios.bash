#!/bin/bash
 
echo "get release rpm from fedora"
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
 
echo "install tools nagios"
yum -y install nagios nagios-devel nagios-plugins*

echo "enable start nagios on boot"
chkconfig nagios on
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/nagios/"
echo "Note, login/passord is nagiosadmin/nagiosadmin"
