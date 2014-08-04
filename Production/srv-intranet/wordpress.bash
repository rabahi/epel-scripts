#!/bin/bash

##################################################
#      PARAMETERS 
##################################################

wp_database_name=wordpress
wp_username=wordpress
wp_password=wordpress


##################################################
#      INSTALLATION SCRIPT
##################################################

echo "install wordpress"
yum -y install wordpress
 
echo "create database $wp_database_name, user/password $wp_username/$wp_password":
mysql --user=root --password=root -e "CREATE USER '$wp_username'@'localhost' IDENTIFIED BY '$wp_password';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS $wp_database_name;"
mysql --user=root --password=root -e "use $wp_database_name; GRANT ALL PRIVILEGES ON $wp_database_name.* TO '$wp_username'@'localhost' WITH GRANT OPTION;"

echo "Note: by default only local users can access to wordpress."
echo "Let's update the file /etc/httpd/conf.d/wordpress.conf and allow everyone."
sed -i "s/\(Deny\s*from\s*All\)/#\1/" /etc/httpd/conf.d/wordpress.conf

echo "configure the database connection here: /usr/share/wordpress/wp-config.php"
sed -i "s/\database_name_here/$wp_database_name/" /usr/share/wordpress/wp-config.php
sed -i "s/\username_here/$wp_username/" /usr/share/wordpress/wp-config.php
sed -i "s/\password_here/$wp_password/" /usr/share/wordpress/wp-config.php

echo "restart httpd"
systemctl restart httpd.service
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/wordpress/"