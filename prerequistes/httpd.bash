#!/bin/bash

echo "install httpd"
yum -y install httpd

echo "activate httpd at startup"
chkconfig httpd on

echo "start service"
service httpd start
