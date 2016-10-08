#!/bin/bash

# get current device (i.e. ens33)
currentDevice=`nmcli d | grep connected | awk '{split($1,a,"\t"); print a[1]}'`

echo "start manually device $currentDevice"
ifup $currentDevice

echo "edit /etc/sysconfig/network-scripts/ifcfg-$currentDevice and set ONBOOT=yes"
sed -i "s/^\(ONBOOT=\).*$/\1yes/g" /etc/sysconfig/network-scripts/ifcfg-$currentDevice
