#!/bin/bash

echo "install openvpn"
yum -y install openvpn

echo "start service openvpn at boot"
chkconfig openvpn on

echo "Append firewall rule to open port 1194 "
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1194  -j ACCEPT
service iptables save
service iptables restart

echo "configure vpn"
rm -f /etc/openvpn/server.conf
cp /usr/share/doc/openvpn-*/sample-config-files/server.conf /etc/openvpn/ 

sed -i "s/dev tun/dev tap0/g" /etc/openvpn/server.conf
sed -i "s/^\(ca \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(cert \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(key \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(dh \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(server \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(ifconfig-pool-persist \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\;\(log\)/\1/g" /etc/openvpn/server.conf
sed -i "s/\(openvpn.log\)/\/var\/log\/\1/g" /etc/openvpn/server.conf

echo "start service"
service openvpn start