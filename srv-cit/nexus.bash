#!/bin/bash

echo "create nexus auto-update script"
mkdir -p /opt/nexus/scripts
mkdir -p /opt/nexus/home

cat > /opt/nexus/scripts/autoupdate.sh << "EOF"
/etc/init.d/tomcat6 stop > /dev/null 2>&1

mkdir -p /opt/nexus/previous
rm -f /opt/nexus/previous/nexus.war > /dev/null 2>&1
mv /opt/java/apache-tomcat-6.0.36/webapps/nexus.war /opt/nexus/previous

wget -O /opt/java/apache-tomcat-6.0.36/webapps/nexus.war http://www.sonatype.org/downloads/nexus-latest.war

/etc/init.d/tomcat6 start
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

echo "install nexus"
chmod a+x /opt/nexus/scripts/autoupdate.sh
/opt/nexus/scripts/autoupdate.sh

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip:8080/nexus"


