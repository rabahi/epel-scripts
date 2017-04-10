#!/bin/bash
 
echo "add ntop repository"
cat > /etc/yum.repos.d/ntop.repo << "EOF"
[ntop]
name=ntop packages
baseurl=http://www.nmon.net/centos-stable/$releasever/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://www.nmon.net/centos-stable/RPM-GPG-KEY-deri
[ntop-noarch]
name=ntop packages
baseurl=http://www.nmon.net/centos-stable/$releasever/noarch/
enabled=1
gpgcheck=1
gpgkey=http://www.nmon.net/centos-stable/RPM-GPG-KEY-deri
EOF

echo "install ntop and redis"
dnf -y install redis ntopng hiredis-devel

cat > /etc/httpd/conf.d/ntopng.conf << "EOF"
ProxyPreserveHost On
Proxypass /ntopng/ http://localhost:3000/ntopng/
Proxypassreverse /ntopng/ http://localhost:3000/ntopng/
ProxyRequests     Off
EOF

echo "enable start ntopng on boot"
systemctl enable ntopng.service
systemctl enable redis.service

echo "start service ntopng and redis"
systemctl restart httpd.service
systemctl start ntopng.service
systemctl start redis.service

echo "configure /etc/ntopng/ntopng.conf, created when service ntopng started".
cat >> /etc/ntopng/ntopng.conf << "EOF"
--http-prefix /ntopng
EOF

echo "restart service ntopng"
systemctl restart ntopng.service

myip=`hostname -I`
echo "Now meet you there: http://$myip/ntopng"
