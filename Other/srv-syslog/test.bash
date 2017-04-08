#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check services:
check_service rsyslog

# check tcp port:
check_tcp 514 #rsyslog

# check pages
check_web_function LogAnalyzer http://localhost/loganalyzer
