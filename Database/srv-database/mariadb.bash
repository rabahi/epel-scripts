#!/bin/bash

echo "install mariadb-server"
dnf -y install mariadb-server phpMyAdmin

echo "activate mariadb at startup"
systemctl enable mariadb.service

echo "start the server"
systemctl start mariadb.service

echo "set password for root. WARN! for this example we choose unsecure password root"
/usr/bin/mysqladmin -u root password 'root'

echo "Note: by default only local users can access to phpMyAdmin."
echo "Let's update the file /etc/httpd/conf.d/phpMyAdmin.conf and allow everyone."
sed -i "s/\(Require\s*ip\s*127.0.0.1\)/Require all granted\n\1/i" /etc/httpd/conf.d/phpMyAdmin.conf
sed -i "s/\(Require\s*ip\\)/#\1/i" /etc/httpd/conf.d/phpMyAdmin.conf

#Uncomment these following lines to open firewall
#echo "add service to firewalld"
#firewall-cmd --permanent --add-service mysql
#firewall-cmd --reload

echo "Now reload httpd"
systemctl reload httpd.service
