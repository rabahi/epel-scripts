#!/bin/bash

# load check_functions.
. ./check_functions/check_functions.bash

# check services:
check_service rpcbind
check_service nfs
check_service nfs-server

# check udp port:
check_udp 111  #portmap
check_udp 2049 #nfsd
check_udp 4045 #NFS lock manager

# check tcp port:
check_tcp 111  #portmap
check_tcp 2049 #nfsd
check_tcp 4045 #NFS lock manager
