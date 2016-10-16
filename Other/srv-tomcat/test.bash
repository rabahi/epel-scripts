#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

#wait program started:
wait_started tomcat /opt/java/apache-tomcat/logs/catalina.out 20

# check commands:
check_command java

# check services:
check_service tomcat

# check tcp port:
check_tcp 8080 #apache tomcat
