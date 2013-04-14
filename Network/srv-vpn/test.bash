#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash

# check services:
check_service openvpn

# check tcp port:
check_tcp 1194 #openvpn