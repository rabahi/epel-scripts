#!/bin/bash
 
echo "install wordpress"
yum -y install wordpress
 
echo "create database wordpress, user/password wordpress/wordpress":
mysql --user=root --password=root -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql --user=root --password=root -e "use wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' WITH GRANT OPTION;"
 
echo "restart httpd"
service httpd restart
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/wordpress/"
echo "Note: by default only local users can access to wordpress. You must update the file /etc/httpd/conf.d/wordpress.conf"
echo "Note: you have to edit and configure the database connection here: /usr/share/wordpress/wp-config.php"
