#!/bin/bash

echo "create nexus auto-update script"
mkdir -p /opt/nexus/bundle
mkdir -p /opt/nexus/scripts

echo "create user nexus"
useradd nexus

#remove nexus as a service if exists
systemctl stop nexus.service
systemctl disable nexus.service

# download latest bundle
rm -fr /opt/nexus/bundle/*
mkdir -p /opt/nexus/download
wget -O /opt/nexus/download/nexus-latest-bundle.tar.gz http://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar xvfz /opt/nexus/download/nexus-latest-bundle.tar.gz -C /opt/nexus/bundle
chown nexus:nexus /opt/nexus/bundle -R

#set nexus as a service
nexusDirectory=`ls /opt/nexus/bundle/ | grep nexus`
sed -i "s/^#?\(run_as_user=R=\s*\).*/\1\"nexus\"/" /opt/nexus/bundle/$nexusDirectory/bin/nexus.rc

cat > /etc/systemd/system/nexus.service << EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
ExecStart=/opt/nexus/bundle/$nexusDirectory/bin/nexus start
ExecStop=/opt/nexus/bundle/$nexusDirectory/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nexus.service
systemctl start nexus.service

rm -fr /opt/nexus/bundle/sonatype-work
ln -s /opt/nexus/sonatype-work /opt/nexus/bundle/sonatype-work
mkdir -p /opt/nexus/sonatype-work
chown nexus:nexus /opt/nexus/sonatype-work/ -R

systemctl start nexus.service


echo "configure httpd (create /etc/httpd/conf.d/nexus.conf)"
cat > /etc/httpd/conf.d/nexus.conf << "EOF"
ProxyPreserveHost On
Proxypass /nexus http://localhost:8081/nexus
Proxypassreverse /nexus http://localhost:8081/nexus
ProxyRequests     Off
EOF
systemctl restart httpd.service

myip=`hostname -I`
echo "Now meet you here: http://$myip/nexus"


