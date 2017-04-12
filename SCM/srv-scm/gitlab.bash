#!/bin/bash

##################################################
#      PARAMETERS 
##################################################

listen_port=6745

##################################################
#      INSTALLATION SCRIPT
##################################################
echo "install gitlab"
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
dnf -y install gitlab-ce
gitlab-ctl reconfigure

echo "configure external url for gitlab"
sed -i "s/^\(external_url\s*\).*/\1'http:\/\/localhost:$listen_port\/gitlab'/" /etc/gitlab/gitlab.rb
gitlab-ctl reconfigure
gitlab-ctl restart

echo "configure httpd (create /etc/httpd/conf.d/gitlab.conf)"
cat > /etc/httpd/conf.d/gitlab.conf << EOF
ProxyPreserveHost On
Proxypass /gitlab http://localhost:$listen_port/gitlab
Proxypassreverse /gitlab http://localhost:$listen_port/gitlab
ProxyRequests     Off
EOF

echo "restart httpd"
systemctl restart httpd.service


myip=`hostname -I`
echo "Now meet you here: http://$myip/gitlab"
