#!/bin/bash
 
echo "add ntop repository"
cat > /etc/yum.repos.d/ntop.repo << "EOF"
[ntop]
name=ntop packages
#baseurl=http://www.nmon.net/centos-stable/$releasever/$basearch/
# use nightly builds until stable version released in el7
baseurl=http://www.nmon.net/centos-stable/7/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://www.nmon.net/centos-stable/RPM-GPG-KEY-deri
EOF

echo "install ntop"
# Some of these packages does not exists in el7 (need to build ourself from source)
yum -y install pfring n2disk nProbe ntopng ntopng-data nbox

echo "ntop configuration directory"
mkdir -p /etc/ntopng
mkdir -p /var/ntop

rm -f /etc/ntopng/ntopng.conf
cp /etc/ntopng/ntopng.conf.sample /etc/ntopng/ntopng.conf

cat > /etc/ntopng/ntopng.start << "EOF"
--local-networks "192.168.184.0/24"
            --interface 0
EOF

cat > /etc/httpd/conf.d/ntopng.conf << "EOF"
ProxyPreserveHost On
Proxypass /ntopng http://localhost:3000
Proxypassreverse /ntopng http://localhost:3000
ProxyRequests     Off
EOF


echo "enable start ntopng on boot"
systemctl enable ntopng.service
systemctl enable redis.service

echo "start service ntopng and redis"
systemctl restart httpd.service
systemctl start ntopng.service
systemctl start redis.service

myip=`hostname -I`
echo "Now meet you there: http://$myip/ntopng"
