#!/bin/bash
 
echo "install ocsinventory"
yum -y install ocsinventory*
 
echo "create database ocsweb, user/password ocs/ocs":
mysql --user=root --password=root -e "CREATE USER 'ocs'@'localhost' IDENTIFIED BY 'ocs';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS ocsweb;"
mysql --user=root --password=root -e "use ocsweb; GRANT ALL PRIVILEGES ON ocsweb.* TO 'ocs'@'localhost' WITH GRANT OPTION;"
 
echo "restart httpd"
systemctl restart httpd.service
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/ocsreports/"
echo "Note the default user/password is admin/admin"
