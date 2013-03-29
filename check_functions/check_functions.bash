#!/bin/bash

echo
echo "##############################################"
echo "############## TEST INSTALLATION #############"
echo "##############################################"
echo

echo -n "include init.d functions"
. /etc/rc.d/init.d/functions
echo_success
echo

# private function
# usage check title command
# example check "checking ls" ls
function check
{
  local title=$1
  local command=$2
  
  echo -n "$title"
  eval "$command > /dev/null 2>&1"
  RETVAL=$?
  if [ $RETVAL -eq 0 ]
  then echo_success
  else echo_failure
  fi
  echo
}

# Check if tcp port is open
# usage: check_tcp myPort
# example check_tcp 80
function check_tcp()
{
  local port=$1
  title="Checking port $port"
  command="netstat -nap | grep :$port"
  check "$title" "$command"
}

# grep
# usage check_grep myPattern myFile
# example: check_grep 
function check_grep()
{
  local pattern=$1
  local file=$2

  title="Checking pattern $pattern in $file"
  command="grep $pattern $file"
  check "$title" "$command"
}

# Check if service is running
# usage: check_service myService
# example check_service httpd
function check_service()
{
  local service=$1
  title="Checking service $service"
  command="ps aux | grep -e '$service' | grep -v grep | wc -l | tr -s \"\n\""
  check "$title" "$command"
}

# Check if command exists
# usage: check_command myCommand
# example check_command ls
function check_command()
{
  local command=$1
  title="Checking command $command"
  command="type -P $command"
  check "$title" "$command"
}

