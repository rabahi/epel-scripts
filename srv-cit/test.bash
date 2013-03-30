#!/bin/bash

# load check_functions.
. ../check_functions/check_functions.bash

#check commands
check_command java

# check pages
check_web_function jenkins http://localhost:8080/jenkins
check_web_function nexus http://localhost:8080/nexus
check_web_function sonar http://localhost:9000

# check services:
check_service tomcat6
check_service sonar
check_service mysqld

# check tcp port:
check_tcp 8080 #httpd
check_tcp 9000 #mysqld
