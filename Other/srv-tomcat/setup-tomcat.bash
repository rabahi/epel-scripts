#!/bin/bash

##################################################
#      PARAMETERS 
##################################################
 
tomcat_version=8.5.16
 
##################################################
#      INSTALLATION SCRIPT
##################################################

echo "install java"
dnf -y install java-1.8.0-openjdk

echo "create user and group tomcat"
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/java/apache-tomcat tomcat

echo "install tomcat"
mkdir -p /opt/java
wget -O /opt/java/apache-tomcat-$tomcat_version.tar.gz http://apache.crihan.fr/dist/tomcat/tomcat-8/v$tomcat_version/bin/apache-tomcat-$tomcat_version.tar.gz
cd /opt/java
tar xvfz apache-tomcat-$tomcat_version.tar.gz

ln -s -f /opt/java/apache-tomcat-$tomcat_version /opt/java/apache-tomcat
chown -R tomcat:tomcat /opt/java/apache-tomcat

echo "create service /etc/systemd/system/tomcat.service"
cat > /etc/systemd/system/tomcat.service << "EOF"
[Unit]
Description=Apache Tomcat
 
[Install]
WantedBy=multi-user.target
 
[Service]
User=tomcat
Group=tomcat
Type=forking
Environment=CATALINA_PID=/opt/java/apache-tomcat/tomcat.pid
Environment=CATALINA_HOME=/opt/java/apache-tomcat
Environment=CATALINA_BASE=/opt/java/apache-tomcat
ExecStart=/opt/java/apache-tomcat/bin/startup.sh
ExecStop=/opt/java/apache-tomcat/bin/shutdown.sh
Restart=on-failure
EOF

systemctl daemon-reload

echo "launch tomcat service at startup"
systemctl enable tomcat.service

echo "add service tomcat (port 8080) to firewall"
cat > /etc/firewalld/services/tomcat.xml << "EOF"
<?xml version="1.0" encoding="utf-8"?>
<service>
 <short>tomcat</short>
 <description>tomcat server</description>
 <port protocol="tcp" port="8080"/>
</service>
EOF
firewall-cmd --permanent --add-service tomcat

echo "launch tomcat"
systemctl start tomcat

myip=`hostname -I`
echo "Now meet you there: http://$myip:8080"
