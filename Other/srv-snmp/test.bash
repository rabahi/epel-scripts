#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check service:
check_service snmpd

# check tcp port:
check_tcp 161  
check_tcp 162  
