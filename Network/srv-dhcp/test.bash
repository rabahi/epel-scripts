#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash


# check services:
check_service dhcpd

# check tcp port:
check_tcp 67 #dhcpd