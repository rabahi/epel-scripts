#!/bin/bash

# load check_functions.
. ../check_functions/check_functions.bash

# check commands:
check_command sendmail

# check services:
check_service postfix
check_service sendmail

# check tcp port:
check_tcp 25 #smtp
