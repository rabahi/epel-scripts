#!/bin/bash

##################################################
#               DEFINES
##################################################
# all version are available here : https://download.centreon.com/

# tab "Centreon Core"
CENTREON_ENGINE_VERSION=1.5.1
CENTREON_BROKER_VERSION=2.11.5
CENTREON_CONNECTOR_VERSION=1.1.2
CENTREON_CLIB_VERSION=1.4.2

# tab "Centreon Web"
CENTREON_WEB_VERSION=2.7.7

# current directory
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

##################################################
#               PREREQUISTES
##################################################

# cmake, gcc
yum -y install cmake make gcc gcc-c++

# qt
yum -y install qt qt-devel

# librrd
yum -y install rrdtool rrdtool-devel

# gnutls
yum -y install gnutls-devel

# perl
yum -y install perl-devel perl-ExtUtils-Embed

# mail
yum -y install mailx

# php
yum -y install php php-pear php-ldap php-intl

# snmp
yum -y install net-snmp

echo "create users abd groups"
groupadd centreon
useradd -g centreon centreon
useradd -g centreon centreon-engine
useradd -g centreon centreon-broker

##################################################
#               CENTREON BROKER
##################################################
echo "create required folders"
mkdir -p /var/log/centreon-broker
mkdir -p /etc/centreon-broker
chown centreon-broker: /var/log/centreon-broker/ -R
chown centreon-broker: /etc/centreon-broker/ -R
chmod 775 /var/log/centreon-broker/ -R
chmod 775 /etc/centreon-broker/ -R

echo "download and build centreon broker"
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-broker/centreon-broker-$CENTREON_BROKER_VERSION.tar.gz
tar -xvf centreon-broker-$CENTREON_BROKER_VERSION.tar.gz
rm -f centreon-broker-$CENTREON_BROKER_VERSION.tar.gz
cd centreon-broker-$CENTREON_BROKER_VERSION/build
cmake                                                           \
  -DWITH_STARTUP_DIR=/etc/init.d                                \
  -DWITH_PREFIX_CONF=/etc/centreon-broker                       \
  -DWITH_PREFIX_LIB=/usr/lib64/nagios                           \
  -DWITH_PREFIX_MODULES=/usr/share/centreon/lib/centreon-broker \
  .
make
make install

# hack under centos 7 ("make install" does not create "cdb" service)
if [ ! -f /etc/init.d/cdb ]; then
    cp $BASEDIR/cdb /etc/init.d
	chmod +x /etc/init.d/cdb
fi


##################################################
#               CENTREON CONNECTOR
##################################################
echo "download and build centreon connector"
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-connectors/centreon-connector-$CENTREON_CONNECTOR_VERSION.tar.gz
tar -xvf centreon-connector-$CENTREON_CONNECTOR_VERSION.tar.gz
rm -f centreon-connector-$CENTREON_CONNECTOR_VERSION.tar.gz
cd centreon-connector-$CENTREON_CONNECTOR_VERSION/perl/build
cmake                                                    \
      -DWITH_PREFIX_BINARY=/usr/lib64/centreon-connector \
	  .
make -j 4
make install

##################################################
#               CENTREON CLIB
##################################################
echo "download and build centreon clib"
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-clib/centreon-clib-$CENTREON_CLIB_VERSION.tar.gz
tar -xvf centreon-clib-$CENTREON_CLIB_VERSION.tar.gz
rm -f centreon-clib-$CENTREON_CLIB_VERSION.tar.gz
cd centreon-clib-$CENTREON_CLIB_VERSION/build
cmake .
make
make install
ln -s /usr/local/lib/libcentreon_clib.so /lib64/libcentreon_clib.so

##################################################
#               CENTREON ENGINE
##################################################
echo "create required folders"
mkdir -p /var/log/centreon-engine
mkdir -p /etc/centreon-engine
chown centreon-engine: /var/log/centreon-engine/ -R
chown centreon-engine: /etc/centreon-engine/ -R
chmod 775 /var/log/centreon-engine/ -R
chmod 775 /etc/centreon-engine/ -R

echo "download and build centreon engine"
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-engine/centreon-engine-$CENTREON_ENGINE_VERSION.tar.gz
tar -xvf centreon-engine-$CENTREON_ENGINE_VERSION.tar.gz
rm -f centreon-engine-$CENTREON_ENGINE_VERSION.tar.gz
cd centreon-engine-$CENTREON_ENGINE_VERSION/build
cmake                                             \
     -DWITH_PREFIX_BIN=/usr/sbin                  \
	 -DWITH_RW_DIR=/var/lib64/centreon-engine/rw  \
	 -DWITH_PREFIX_LIB=/usr/lib64/centreon-engine \
	 .
make
make install

##################################################
#               CENTREON WEB
##################################################
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon/centreon-web-$CENTREON_WEB_VERSION.tar.gz
tar -xvf centreon-web-$CENTREON_WEB_VERSION.tar.gz
rm -f centreon/centreon-web-$CENTREON_WEB_VERSION.tar.gz
cd  centreon-web-$CENTREON_WEB_VERSION

# install centreon web :
dos2unix $BASEDIR/centreon-response.txt
./install.sh -f $BASEDIR/centreon-response.txt


##################################################
#  POST INSTALLATION CONFIGURATION
##################################################

echo "configure apache for apache 2.4"
cat > /etc/httpd/conf.d/centreon.conf << "EOF"
Alias /centreon /usr/local/centreon/www/
<Directory "/usr/local/centreon/www">
    Options Indexes
    AllowOverride AuthConfig Options
    Require all granted
</Directory>
EOF

echo "configure default timezone in php.ini"
sed -i "s/^;\(date.timezone =\).*/\1Europe\/Paris/g" /etc/php.ini

echo "enable write to SmartyCache directory"
chown centreon: /usr/local/centreon/GPL_LIB/SmartyCache/ -R

echo "restart httpd"
systemctl restart httpd

echo "add option 'innodb_file_per_table=1' to /etc/my.cnf"
if ! grep -q innodb_file_per_table=1 /etc/my.cnf; then
  sed -i 's/\(\[mysqld\]\)/\1\ninnodb_file_per_table=1/' /etc/my.cnf
  systemctl restart mariadb.service
fi;

echo "create databases and grant amm privileges to user/password centreon/centreon":
mysql --user=root --password=root -e "CREATE USER 'centreon'@'localhost' IDENTIFIED BY 'centreon';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS centreon;"
mysql --user=root --password=root -e "use centreon; GRANT ALL PRIVILEGES ON centreon.* TO 'centreon'@'localhost' WITH GRANT OPTION;"

mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS centreon_status;"
mysql --user=root --password=root -e "use centreon_status; GRANT ALL PRIVILEGES ON centreon_status.* TO 'centreon'@'localhost' WITH GRANT OPTION;"

## meet you
myip=`hostname -I`
echo "Now meet you here: http://$myip/centreon/"