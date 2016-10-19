#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check pages
check_web_function WordPress http://localhost/wordpress
check_web_function mediawiki http://localhost/mediawiki

# check services:
check_service httpd
check_service mariadb

# check tcp port:
check_tcp 80 #httpd
check_tcp 3306 #mariadb
