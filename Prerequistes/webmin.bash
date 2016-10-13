#!/bin/bash

echo "install webmin"
yum -y install webmin

myip=`hostname -I`

echo "configure webmin"
echo "webprefix=/webmin" >> /etc/webmin/config
echo "webprefixnoredir=1" >> /etc/webmin/config
#echo "referers=localhost" >> /etc/webmin/config
echo "referer=$myip" >> /etc/webmin/config
echo "cookiepath=/webmin" >> /etc/webmin/miniserv.conf

echo "configure httpd proxy"
cat > /etc/httpd/conf.d/webmin.conf << "EOF"
ProxyPreserveHost On
Proxypass /webmin http://localhost:10000
Proxypassreverse /webmin http://localhost:10000
ProxyRequests Off
EOF

echo "remove ssl (for httpd proxy)"
sed -i "s/^\(ssl=\).*/\10/" /etc/webmin/miniserv.conf

echo "launch webmin"
systemctl start webmin.service

echo "reload httpd"
systemctl restart httpd.service

echo "launch webmin on boot"
systemctl enable webmin.service
