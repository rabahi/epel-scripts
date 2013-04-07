#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash

# check pages
check_web_function WordPress http://localhost/wordpress

# check services:
check_service httpd
check_service mysqld

# check tcp port:
check_tcp 80 #httpd
check_tcp 3306 #mysqld
