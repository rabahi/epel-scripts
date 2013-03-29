#!/bin/bash

echo "create jenkins auto-update script"
mkdir -p /opt/jenkins/scripts
mkdir -p /opt/jenkins/home

cat > /opt/jenkins/scripts/autoupdate.sh << "EOF"
/etc/init.d/tomcat6 stop > /dev/null 2>&1

mkdir -p /opt/jenkins/previous
rm -f /opt/jenkins/previous/jenkins.war > /dev/null 2>&1
mv /opt/java/apache-tomcat-6.0.36/webapps/jenkins.war /opt/jenkins/previous

wget -O /opt/java/apache-tomcat-6.0.36/webapps/jenkins.war http://mirrors.jenkins-ci.org/war/latest/jenkins.war

/etc/init.d/tomcat6 start
EOF

echo "add autoupdate script to crontab"
if ! grep -q JENKINS /etc/crontab; then
echo "" >> /etc/crontab
echo "######## JENKINS #######" >> /etc/crontab
echo "every saturday at 8h05" >> /etc/crontab
echo "5 8 * * 6 root chmod a+x /opt/jenkins/scripts/autoupdate.sh; /opt/jenkins/scripts/autoupdate.sh" >> /etc/crontab
echo "######## JENKINS #######" >> /etc/crontab
fi

echo "set JENKINS_HOME"
if ! grep -q JENKINS ~/.bashrc; then
echo "" >> ~/.bashrc
echo "######## JENKINS #######" >> ~/.bashrc
echo "export JENKINS_HOME=/opt/jenkins/home" >> ~/.bashrc
echo "######## JENKINS #######" >> ~/.bashrc
source ~/.bashrc
fi

echo "install jenkins"
chmod a+x /opt/jenkins/scripts/autoupdate.sh
/opt/jenkins/scripts/autoupdate.sh

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip:8080/jenkins"

