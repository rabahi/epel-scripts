#!/bin/bash

echo "install openldap-servers"
yum -y install openldap-servers

echo "start service slapd at boot"
chkconfig slapd on
 
echo "start service"
service slapd start
