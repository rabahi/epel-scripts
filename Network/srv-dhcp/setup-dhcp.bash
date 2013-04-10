#!/bin/bash

echo "install dhcp"
yum -y install dhcp
 
echo "start service dhcpd at boot"
chkconfig dhcpd on
 
echo "configure /etc/sysconfig/dhcpd and /etc/sysconfig/dhcpd6"
sed -i "s/^(DHCPDARGS=\)$/\1eth0/" /etc/sysconfig/dhcpd
sed -i "s/^(DHCPDARGS=\)$/\1eth0/" /etc/sysconfig/dhcpd6

echo "configure /etc/dhcp/dhcpd.conf"

myprefixIP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d. -f1,2,3| awk '{ print $1}'`

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
 range a.b.c.10 a.b.c.100;
}
EOF

sed -i "s/a.b.c/$myprefixIP/g" /etc/dhcp/dhcpd.conf



echo "start service"
service dhcpd start