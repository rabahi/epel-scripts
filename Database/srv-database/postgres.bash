#!/bin/bash

echo "install postgresql server"
yum -y install postgresql-server phpPgAdmin

echo "initialize database"
postgresql-setup initdb
sudo -u postgres createuser root
sudo -u postgres createdb mydatabase

echo "activate postgresql at startup"
systemctl enable postgresql.service

echo "start the server"
systemctl start postgresql.service

echo "Note: by default only local users can access to phpPgAdmin."
echo "Let's update the file /etc/httpd/conf.d/phpPgAdmin.conf and allow everyone."
sed -i "s/\(Deny\s*from\s*All\)/#\1/i" /etc/httpd/conf.d/phpPgAdmin.conf
sed -i "s/\(Allow\s*from\s*127.0.0.1\)/#\1/i" /etc/httpd/conf.d/phpPgAdmin.conf
sed -i "s/\(Allow\s*from\s*::1\)/#\1/i" /etc/httpd/conf.d/phpPgAdmin.conf

echo "Now reload httpd"
systemctl reload httpd.service