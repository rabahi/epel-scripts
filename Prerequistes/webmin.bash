#!/bin/bash

echo "install webmin"
yum -y install webmin

echo "configure webmin"
echo "webprefix=/webmin" >> /etc/webmin/config
echo "webprefixnoredir=1" >> /etc/webmin/config
echo "referers=localhost" >> /etc/webmin/config
echo "referer=1" >> /etc/webmin/config

cat > /etc/httpd/conf.d/webmin.conf << "EOF"
ProxyPreserveHost On
Proxypass /webmin http://localhost:10000
Proxypassreverse /webmin http://localhost:10000
ProxyRequests Off
EOF

echo "launch webmin"
systemctl start webmin.service

echo "reload httpd"
systemctl restart httpd.service

echo "launch webmin on boot"
systemctl enable webmin.service
