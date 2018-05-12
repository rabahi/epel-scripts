#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# get current device (i.e. ens33)
currentDevice=`nmcli d | grep connected | awk '{split($1,a,"\t"); print a[1]}'`
# check network on boot:
check_grep "ONBOOT=yes" "/etc/sysconfig/network-scripts/ifcfg-$currentDevice"

# check selinux
check_grep "SELINUX=disabled" "/etc/selinux/config"

# check services
check_service firewalld
check_service ntpd
check_service httpd
check_service mariadb
check_service yum-cron
check_service nrpe
check_service webmin

# check commands:
check_command firewall-cmd
check_command locate
check_command wget
check_command dos2unix
check_command telnet

# check tcp port:
check_tcp 22 #sshd
check_tcp 80 #httpd  (http)
check_tcp 443 #httpd (https)
check_tcp 3306 #mysqld
check_tcp 5666 #nrpe
check_tcp 10000 #webmin

# check pages
check_web_function phpMyAdmin "http://localhost/phpMyAdmin/ --http-user=root --http-password=root"
