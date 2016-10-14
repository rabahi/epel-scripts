#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

#wait program started:
wait_started jenkins /var/log/jenkins/jenkins.log 60
wait_started sonar /opt/sonar/logs/sonar.log 60

#check commands
check_command java

# check pages
check_web_function jenkins http://localhost/jenkins/login
check_web_function Nexus http://localhost/nexus
check_web_function sonar http://localhost/sonar

# check services:
check_service sonar
check_service mariadb
check_service jenkins

# check tcp port:
check_tcp 80   #httpd
check_tcp 3306 #mariadb
