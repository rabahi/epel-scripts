#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check commands:
check_command sendmail

# check services:
check_service master    #postfix
#check_service sendmail
check_service dovecot

# check tcp port:
check_tcp 25 #smtp
check_tcp 110 #pop3
check_tcp 143 #imap
