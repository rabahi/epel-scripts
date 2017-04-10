#!/bin/bash

##################################################
#      PARAMETERS 
##################################################

database_name=mediawiki
database_username=mediawiki
database_password=mediawiki


##################################################
#             INSTALL MEDIAWIKI
##################################################
echo "install prerequistes"
dnf -y install php-mbstring php-xml php-intl php-gd texlive php-mysqli php-xcache


echo "create database $database_name, user/password $database_username/$database_password":
mysql --user=root --password=root -e "CREATE USER '$database_username'@'localhost' IDENTIFIED BY '$database_password';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS $database_name;"
mysql --user=root --password=root -e "use $database_name; GRANT ALL PRIVILEGES ON $database_name.* TO '$database_username'@'localhost' WITH GRANT OPTION;"

echo "download mediawiki"
cd /tmp
wget http://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.4.tar.gz
tar xvfz mediawiki-1.26.4.tar.gz
mv mediawiki-1.26.4 /var/www/html/mediawiki


echo "restart httpd"
systemctl restart httpd.service
 
myip=`hostname -I`
echo "Now meet you here: http://$myip/mediawiki/"