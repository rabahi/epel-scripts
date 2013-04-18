#!/bin/bash

echo "start manually"
ifup eth0

echo "edit /etc/sysconfig/network-scripts/ifcfg-eth0 and set ONBOOT=yes"
sed -i "s/^\(ONBOOT=\).*$/\1yes/g" /etc/sysconfig/network-scripts/ifcfg-eth0