#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash

# check services:
check_service smb

# check tcp port:
check_tcp 445 #smb