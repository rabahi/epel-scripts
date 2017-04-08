#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check pages
check_web_function subversion http://localhost/svn/
check_web_function git http://localhost/git/
check_web_function hg http://localhost/hg/
check_web_function GitLab http://localhost/gitlab/

# check services:
check_service httpd

# check tcp port:
check_tcp 80 #httpd

