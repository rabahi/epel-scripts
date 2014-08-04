#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check services:
check_service vsftpd

# check tcp port:
check_tcp 21 #ftp