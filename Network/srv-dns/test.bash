#!/bin/bash

# load check_functions.
. ../../check_functions/check_functions.bash


# check services:
check_service named

# check tcp port:
check_tcp 53 # named (i.e. dns)

