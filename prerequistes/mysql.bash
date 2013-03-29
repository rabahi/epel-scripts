#!/bin/bash

echo "install mysql-server"
yum -y install mysql-server.x86_64

echo "activate mysqld at startup"
chkconfig mysqld on

echo "start the server"
service mysqld start

echo "set password for root. WARN! for this example we choose unsecure password root"
/usr/bin/mysqladmin -u root password 'root'
