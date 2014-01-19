#!/bin/bash

echo "install bind"
yum -y install  bind bind-libs bind-utils
 
echo "start service named at boot"
chkconfig named on

echo "get current network interface"
currentEth=`ls /sys/class/net | grep eth | head -1`

echo "Open port 53"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT
service iptables save
service iptables restart

echo "create my-domain.local.fwd"
cat > /var/named/my-domain.local.fwd << "EOF"
$ORIGIN my-domain.local.

$TTL 3D

@       SOA     dns.my-domain.local.     root.my-domain.local. (12 4h 1h 1w 1h)

@       IN      NS      dns.my-domain.local.

dns.my-domain.local.     IN      A       mylocalIP

www                                     IN      A       mylocalIP

EOF

mylocalIP=`/sbin/ifconfig $currentEth | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
sed -i "s/mylocalIP/$mylocalIP/g" /var/named/my-domain.local.fwd

echo "create my-domain.local.rev"
cat > /var/named/my-domain.local.rev << "EOF"
$ORIGIN mylocalIP3.mylocalIP2.mylocalIP1.in-addr.arpa.

$TTL 3D

@       SOA     dns.my-domain.local.     root.my-domain.local. (12 4h 1h 1w 1h)

@       IN      NS      dns.my-domain.local.

mylocalIP4     IN      PTR     dns.my-domain.local.

EOF

mylocalIP1=`/sbin/ifconfig $currentEth | grep 'inet addr:' | cut -d: -f2 | cut -d. -f1| awk '{ print $1}'`
mylocalIP2=`/sbin/ifconfig $currentEth | grep 'inet addr:' | cut -d: -f2 | cut -d. -f2| awk '{ print $1}'`
mylocalIP3=`/sbin/ifconfig $currentEth | grep 'inet addr:' | cut -d: -f2 | cut -d. -f3| awk '{ print $1}'`
mylocalIP4=`/sbin/ifconfig $currentEth | grep 'inet addr:' | cut -d: -f2 | cut -d. -f4| awk '{ print $1}'`

sed -i "s/mylocalIP1/$mylocalIP1/g" /var/named/my-domain.local.rev
sed -i "s/mylocalIP2/$mylocalIP2/g" /var/named/my-domain.local.rev
sed -i "s/mylocalIP3/$mylocalIP3/g" /var/named/my-domain.local.rev
sed -i "s/mylocalIP4/$mylocalIP4/g" /var/named/my-domain.local.rev

echo "Now add zone to named.conf"
cat >> /etc/named.conf << "EOF"
zone "my-domain.local" {
        type master;
        file "my-domain.local.fwd";
};
zone "mylocalIP3.mylocalIP2.mylocalIP1.in-addr.arpa" {
        type master;
        file "my-domain.local.rev";
};
EOF

sed -i "s/mylocalIP1/$mylocalIP1/g" /etc/named.conf
sed -i "s/mylocalIP2/$mylocalIP2/g" /etc/named.conf
sed -i "s/mylocalIP3/$mylocalIP3/g" /etc/named.conf

echo "Now enable query from all network (WARNING you should have a look at this to improve your network security!)"
sed -i "s/\(listen-on port\)/\/\/\1/g" /etc/named.conf
sed -i "s/\(listen-on-v6 port\)/\/\/\1/g" /etc/named.conf
sed -i "s/\(allow-query\)/\/\/\1/g" /etc/named.conf


echo "start service"
service named restart