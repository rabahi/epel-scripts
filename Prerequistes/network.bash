#!/bin/bash

echo "start manually"
ifup ens33

echo "edit /etc/sysconfig/network-scripts/ifcfg-ens33 and set ONBOOT=yes"
sed -i "s/^\(ONBOOT=\).*$/\1yes/g" /etc/sysconfig/network-scripts/ifcfg-ens33