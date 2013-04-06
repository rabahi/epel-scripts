#!/bin/bash

echo "install wordpress"
yum -y install wordpress
 
echo "create database wordpress, user/password wordpress/wordpress":
mysql --user=root --password=root -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql --user=root --password=root -e "use wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' WITH GRANT OPTION;"

echo "Note: by default only local users can access to wordpress."
echo "Let's update the file /etc/httpd/conf.d/wordpress.conf and allow everyone."
sed -i "s/\(Deny\s*from\s*All\)/#\1/" /etc/httpd/conf.d/wordpress.conf

echo "configure the database connection here: /usr/share/wordpress/wp-config.php"
sed -i "s/\database_name_here/wordpress/" /usr/share/wordpress/wp-config.php
sed -i "s/\username_here/wordpress/" /usr/share/wordpress/wp-config.php
sed -i "s/\password_here/wordpress/" /usr/share/wordpress/wp-config.php

echo "restart httpd"
service httpd restart
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/wordpress/"