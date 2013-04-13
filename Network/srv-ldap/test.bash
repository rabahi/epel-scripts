#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash

# check services:
check_service slapd

# check commands:
check_command ldapsearch
check_command slappasswd

# check tcp port:
check_tcp 389 #slapd