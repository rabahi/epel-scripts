#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check services:
check_service openvpn@server.service

# check udp port:
check_udp 1194 #openvpn
