#!/bin/bash

echo "install mysql-server"
yum -y install mysql-server phpmyadmin

echo "activate mysqld at startup"
chkconfig mysqld on

echo "start the server"
service mysqld start

echo "set password for root. WARN! for this example we choose unsecure password root"
/usr/bin/mysqladmin -u root password 'root'

echo "Note: by default only local users can access to phpmyadmin."
echo "Let's update the file /etc/httpd/conf.d/phpmyadmin.conf and allow everyone."
sed -i "s/\(Deny\s*from\s*All\)/#\1/" /etc/httpd/conf.d/phpmyadmin.conf

echo "Now reload httpd"
service httpd reload