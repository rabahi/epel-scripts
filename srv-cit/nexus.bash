#!/bin/bash

echo "create nexus auto-update script"
mkdir -p /opt/nexus/bundle
mkdir -p /opt/nexus/scripts

echo "create user nexus"
useradd nexus

cat > /opt/nexus/scripts/autoupdate.sh << "EOF"
#remove nexus as a service
service nexus stop
chkconfig --del nexus
rm -f /etc/init.d/nexus

# download latest bundle
rm -fr /opt/nexus/bundle/*
mkdir -p /opt/nexus/download
wget -O /opt/nexus/download/nexus-latest-bundle.tar.gz http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz
tar xvfz /opt/nexus/download/nexus-latest-bundle.tar.gz -C /opt/nexus/bundle
chown nexus:nexus /opt/nexus/bundle -R

#set nexus as a service
nexusDirectory=`ls /opt/nexus/bundle/ | grep nexus`
ln -s /opt/nexus/bundle/$nexusDirectory/bin/nexus /etc/init.d/nexus
sed -i "s/^#\(RUN_AS_USER=\s*\).*/\1nexus/" /opt/nexus/bundle/$nexusDirectory/bin/nexus
chkconfig --add nexus
chkconfig --levels 345 nexus on
service nexus start
EOF

echo "add autoupdate script to crontab"
if ! grep -q NEXUS /etc/crontab; then
echo "" >> /etc/crontab
echo "######## NEXUS #######" >> /etc/crontab
echo "every sunday at 8h05" >> /etc/crontab
echo "5 8 * * 0 root chmod a+x /opt/nexus/scripts/autoupdate.sh; /opt/nexus/scripts/autoupdate.sh" >> /etc/crontab
echo "######## NEXUS #######" >> /etc/crontab
fi

echo "set nexus_HOME"
if ! grep -q NEXUS ~/.bashrc; then
echo "" >> ~/.bashrc
echo "######## NEXUS #######" >> ~/.bashrc
echo "export NEXUS_HOME=/opt/nexus/home" >> ~/.bashrc
echo "######## NEXUS #######" >> ~/.bashrc
source ~/.bashrc
fi

echo "configure httpd (create /etc/httpd/conf.d/nexus.conf)"
cat > /etc/httpd/conf.d/nexus.conf << "EOF"
ProxyPreserveHost On
Proxypass /nexus http://localhost:8081/nexus
Proxypassreverse /nexus http://localhost:8081/nexus
ProxyRequests     Off
EOF
service httpd restart

echo "install nexus"
chmod a+x /opt/nexus/scripts/autoupdate.sh
/opt/nexus/scripts/autoupdate.sh


myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/nexus"


