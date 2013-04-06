#!/bin/bash

# load check_functions.
. ../check_functions/check_functions.bash

# check network on boot:
check_grep "ONBOOT=yes" "/etc/sysconfig/network-scripts/ifcfg-eth0"

# check selinux
check_grep "SELINUX=disabled" "/etc/selinux/config"

# check services
check_service ntpd
check_service httpd
check_service mysqld
check_service yum-cron
check_service nrpe

# check commands:
check_command locate
check_command wget
check_command dos2unix
check_command telnet


# check tcp port:
check_tcp 22 #sshd
check_tcp 80 #httpd
check_tcp 3306 #mysqld
check_tcp 5666 #nrpe

