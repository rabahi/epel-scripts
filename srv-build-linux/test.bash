#!/bin/bash

# load check_functions.
. ../check_functions/check_functions.bash

# check commands:
check_command mock
check_command aclocal
check_command automake
check_command autoconf
check_command rpmdev-newspec
check_command rpmbuild
check_command rpmlint


# check pages
check_web_function repoview http://localhost/rpm/centos/6/x86_64/repoview/index.html

# check services:
check_service httpd

# check tcp port:
check_tcp 80 #httpd

