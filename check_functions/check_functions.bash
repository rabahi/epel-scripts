#!/bin/bash

echo
echo "##############################################"
echo "############## TEST INSTALLATION #############"
echo "##############################################"
echo

##################################################
#      PRIVATE FUNCTIONS 
##################################################

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

##################################################
#      CHECK FUNCTIONS
##################################################

# Check if tcp port is open
# usage: check_tcp myPort
# example check_tcp 80
function check_tcp()
{
  local port=$1
  title="Checking tcp port $port"
  command="netstat -nap | grep :$port"
  check "$title" "$command"
}

# Check if udp port is open
# usage: check_udp myPort
# example check_udp 80
function check_udp()
{
  local port=$1
  title="Checking udp port $port"
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

# Check if word exists in url page
# usage: check_web_function myWord myUrl
# example check_web_function google http://google.com
function check_web_function()
{  
  local word=$1
  local url=$2
  
  title="Checking word $word exists in url $url"
  command="wget -q -O /tmp/url $url; grep $word /tmp/url"
  check "$title" "$command"
}

# Check if file exists
# usage: check_file_exists myFile
# example check_file_exists /etc/issue
function check_file_exists()
{  
  local file=$1  
  
  title="Checking file $file exists"
  command="test -e $file"
  check "$title" "$command"
}


##################################################
#      TOOLS FUNCTIONS 
##################################################

# Wait program finish to start (it will stop to write in log file)
# usage: wait_started myProgram myLogFile [myWaitTime]
# examples:
#   wait_started httpd /var/log/httpd/access.log
#   wait_started httpd /var/log/httpd/access.log 2
function wait_started()
{
  local program=$1
  local logFile=$2
  local waitTime=10 #in second
  if [ -n "$3" ]; then
    waitTime=$3 
  fi
 
  echo "waiting for $program (check every $waitTime s)..."
  wcPrevious=`cat $logFile | wc -l`
  wcCurrent=-1
  while [ $wcCurrent -lt  $wcPrevious ];
  do
   wcPrevious=$wcCurrent
   wcCurrent=`cat $logFile | wc -l`
   echo -n "$program has $wcCurrent lines in log"
   sleep $waitTime
  done
  echo
}
