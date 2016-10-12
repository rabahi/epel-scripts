#!/bin/bash

echo "install dhcp"
yum -y install dhcp
 
echo "start service dhcpd at boot"
systemctl enable dhcpd.service

echo "get current network interface"
currentDevice=`nmcli d | grep connected | awk '{split($1,a,"\t"); print a[1]}'`

echo "configure /etc/sysconfig/dhcpd and /etc/sysconfig/dhcpd6"
sed -i "s/^(DHCPDARGS=\).*/\1$currentDevice/" /etc/sysconfig/dhcpd
sed -i "s/^(DHCPDARGS=\).*/\1$currentDevice/" /etc/sysconfig/dhcpd6

echo "configure /etc/dhcp/dhcpd.conf"

myprefixIP=`/sbin/ifconfig $currentDevice | grep 'inet addr:' | cut -d: -f2 | cut -d. -f1,2,3| awk '{ print $1}'`

cat > /etc/dhcp/dhcpd.conf << "EOF"
ddns-update-style none;
authoritative;
log-facility local7;
default-lease-time 600;
max-lease-time 7200;
option subnet-mask 255.255.255.0;
option broadcast-address a.b.c.255;
option routers a.b.c.1;
option domain-name-servers a.b.c.1;
option domain-name "centos.local";
subnet a.b.c.0 netmask 255.255.255.0 {
 range a.b.c.10 a.b.c.254;
}
EOF

sed -i "s/a.b.c/$myprefixIP/g" /etc/dhcp/dhcpd.conf


echo "add service dhcp (port 67) to firewall"
firewall-cmd --permanent --add-service dhcp

echo "start service"
systemctl start dhcpd.service
