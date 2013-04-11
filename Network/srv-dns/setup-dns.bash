#!/bin/bash

echo "install bind"
yum -y install  bind bind-libs bind-utils
 
echo "start service named at boot"
chkconfig named on

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

mylocalIP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
sed -i "s/mylocalIP/$mylocalIP/g" /var/named/my-domain.local.fwd

echo "create my-domain.local.rev"
cat > /var/named/my-domain.local.rev << "EOF"
$ORIGIN mylocalIP3.mylocalIP2.mylocalIP1.in-addr.arpa.

$TTL 3D

@       SOA     dns.my-domain.local.     root.my-domain.local. (12 4h 1h 1w 1h)

@       IN      NS      dns.my-domain.local.

mylocalIP4     IN      PTR     dns.my-domain.local.

EOF

mylocalIP1=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d. -f1| awk '{ print $1}'`
mylocalIP2=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d. -f2| awk '{ print $1}'`
mylocalIP3=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d. -f3| awk '{ print $1}'`
mylocalIP4=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | cut -d. -f4| awk '{ print $1}'`

sed -i "s/mylocalIP1/$mylocalIP1/g" /var/named/my-domain.local.fwd
sed -i "s/mylocalIP2/$mylocalIP2/g" /var/named/my-domain.local.fwd
sed -i "s/mylocalIP3/$mylocalIP3/g" /var/named/my-domain.local.fwd
sed -i "s/mylocalIP4/$mylocalIP4/g" /var/named/my-domain.local.fwd

echo "Now add zone to named.conf"
cat >> /etc/named.conf << "EOF"
zone "my-domain.local" {
        type master;
        file "my-domain.local.fwd";
};
zone "184.168.192.in-addr.arpa" {
        type master;
        file "my-domain.local.rev";
};
EOF

echo "start service"
service named start