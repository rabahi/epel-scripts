#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# test samba configuration
check "Test samba configuration" "testparm -s"

# check services:
check_service smb

# check tcp port:
check_tcp 445 #smb