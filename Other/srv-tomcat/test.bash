#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash

# check commands:
check_command java

# check services:
check_service tomcat6

# check tcp port:
check_tcp 8080 #apache tomcat
