#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check services
check_service mariadb
check_service postgresql

# check tcp port:
check_tcp 3306 #mariadb
check_tcp 5432 #postgresql

# check pages
check_web_function phpMyAdmin "http://localhost/phpMyAdmin/ --http-user=root --http-password=root"
check_web_function phpPgAdmin "http://localhost/phpPgAdmin/ --http-user=root --http-password=root"
