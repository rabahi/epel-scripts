#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check commands:
check_command node

# check services:
check_service myNodeJsService

# check tcp port:
check_tcp 4587 #myNodeJsService
