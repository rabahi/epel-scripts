#!/bin/bash
 
echo "install glpi"
yum -y install glpi*
 
echo "create database glpi, user/password glpi/glpi":
mysql --user=root --password=root -e "CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpi';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS glpi;"
mysql --user=root --password=root -e "use glpi; GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost' WITH GRANT OPTION;"
 
echo "restart httpd"
systemctl restart httpd.service
 
myip=`hostname -I`
echo "Now meet you here: http://$myip/glpi/"
echo "Note the default user/password is glpi/glpi"
