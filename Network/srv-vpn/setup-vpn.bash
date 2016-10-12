#!/bin/bash

echo "install openvpn"
yum -y install openvpn

echo "start service openvpn at boot"
systemctl enable openvpn@server.service

echo "add service openvpn (port 1194) to firewall"
firewall-cmd --permanent --add-service openvpn
firewall-cmd --reload

echo "configure vpn"
rm -f /etc/openvpn/server.conf
cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn/ 

sed -i "s/dev tun/dev tap0/g" /etc/openvpn/server.conf
sed -i "s/^\(ca \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(cert \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(key \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(dh \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(server \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\(ifconfig-pool-persist \)/#\1/g" /etc/openvpn/server.conf
sed -i "s/^\;\(log\)/\1/g" /etc/openvpn/server.conf
sed -i "s/\(openvpn.log\)/\/var\/log\/\1/g" /etc/openvpn/server.conf


# echo "SSL Part (disabled)"
# echo "If uncomment:"
# echo " - Remember to sign and commit (when it will be asked)"
# echo " - In /etc/openvpn/server.conf:"
# echo "       * update ca, cert, key dh path"
# echo "       * uncomment and configure the server-bridge (syntax [VPN server's IP] [subnetmask] [the range of IP for client])"
# echo "       * uncomment and configure the 'push \"route\ (...)\" (syntax [network VPN server in] [subnetmask])"
# cp -R /usr/share/openvpn/easy-rsa/2.0 /etc/openvpn/easy-rsa
# cd /etc/openvpn/easy-rsa
# ln -s openssl-1.0.0.cnf openssl.cnf
# source ./vars
# ./clean-all
# ./build-ca
# ./build-key-server server 
# ./build-dh
# ./build-key-pass client 

echo "start service"
systemctl start openvpn@server.service
