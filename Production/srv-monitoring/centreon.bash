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
yum -y install php-pear

# snmp
yum -y install net-snmp

echo "create users abd groups"
groupadd centreon
useradd -g centreon centreon
useradd -g centreon centreon-engine
useradd -g centreon centreon-broker

##################################################
#               CENTREON ENGINE
##################################################
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-engine/centreon-engine-$CENTREON_ENGINE_VERSION.tar.gz
tar -xvf centreon-engine-$CENTREON_ENGINE_VERSION.tar.gz
rm -f centreon-engine-$CENTREON_ENGINE_VERSION.tar.gz
cd centreon-engine-$CENTREON_ENGINE_VERSION/build
cmake .
make
make install


##################################################
#               CENTREON BROKER
##################################################
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-broker/centreon-broker-$CENTREON_BROKER_VERSION.tar.gz
tar -xvf centreon-broker-$CENTREON_BROKER_VERSION.tar.gz
rm -f centreon-broker-$CENTREON_BROKER_VERSION.tar.gz
cd centreon-broker-$CENTREON_BROKER_VERSION/build
cmake -DWITH_STARTUP_DIR=/etc/init.d .
make
make install

# hack under centos 7 ("make install" does not create "cdb" service)
cp $BASEDIR/cdb /etc/init.d

##################################################
#               CENTREON CONNECTOR
##################################################
cd /tmp
wget https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-connectors/centreon-connector-$CENTREON_CONNECTOR_VERSION.tar.gz
tar -xvf centreon-connector-$CENTREON_CONNECTOR_VERSION.tar.gz
rm -f centreon-connector-$CENTREON_CONNECTOR_VERSION.tar.gz
cd centreon-connector-$CENTREON_CONNECTOR_VERSION/perl/build
cmake .
make -j 4
make install

##################################################
#               CENTREON CLIB
##################################################
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
#               APACHE CONFIGURATION
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

