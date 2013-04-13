#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash

# check services:
check_service rpcbind
check_service nfs