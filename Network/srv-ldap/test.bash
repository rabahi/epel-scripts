#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# test ldap configuration
check "Test ldap configuration" "slaptest -u"

# check services:
check_service slapd

# check commands:
check_command ldapsearch
check_command slappasswd

# check tcp port:
check_tcp 389 #slapd

# check pages
check_web_function phpldapadmin "http://localhost/phpldapadmin/ --http-user=root --http-password=root"