#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check commands:
check_command mock
check_command aclocal
check_command automake
check_command autoconf
check_command rpmdev-newspec
check_command rpmbuild
check_command rpmlint


# check pages
check_web_function Repoview http://localhost/rpm/centos/7/x86_64/repoview/index.html

# check services:
check_service httpd

# check tcp port:
check_tcp 80 #httpd

# check example rpm exists
check_file_exists /root/rpmbuild/SPECS/hello.spec
check_file_exists /root/rpmbuild/SRPMS/hello-1.0-1.el7.centos.src.rpm
check_file_exists /root/rpmbuild/RPMS/x86_64/hello-1.0-1.el7.centos.x86_64.rpm
