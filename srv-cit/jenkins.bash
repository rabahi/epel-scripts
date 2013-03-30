#!/bin/bash

echo "import repository jenkins"
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

echo "install java and jenkins"
yum -y install java-1.6.0-openjdk jenkins


echo "configure httpd (create /etc/httpd/conf.d/jenkins.conf)"
cat > /etc/httpd/conf.d/jenkins.conf << "EOF"
ProxyPreserveHost On
Proxypass /jenkins http://localhost:8080/jenkins
Proxypassreverse /jenkins http://localhost:8080/jenkins
ProxyRequests     Off
EOF


echo "configure jenkins"

#change home directory
mkdir -p /opt/jenkins_home
chown jenkins:jenkins /opt/jenkins_home -R
sed -i "s/^\(JENKINS_HOME=\).*/\1\"\/opt\/jenkins_home\"/" /etc/sysconfig/jenkins

#configure jenkins prefix tu run begin apache:
sed -i "s/^\(JENKINS_ARGS=\).*/\1\"--prefix=\/jenkins\"/" /etc/sysconfig/jenkins

#Security-Enhanced Linux (SE-Linux)
setsebool -P httpd_can_network_connect true

echo "start jenkins"
service httpd restart
service jenkins start


myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/jenkins"

