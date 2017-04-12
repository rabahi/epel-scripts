#!/bin/bash

echo "install gitlab"
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
dnf -y install gitlab-ce
gitlab-ctl reconfigure

echo "configure external url for gitlab"
sed -i "s/^\(external_url\s*\).*/\1'http:\/\/localhost:6745\/gitlab'/" /etc/gitlab/gitlab.rb
sed -i "s/^#\s*\(nginx\['enable'\]\s*=\s*\).*/\1false/" /etc/gitlab/gitlab.rb
sed -i "s/^#\s*\(web_server\['external_users'\]\s*=\s*\).*/\1\['apache'\]/" /etc/gitlab/gitlab.rb
gitlab-ctl reconfigure
gitlab-ctl restart

echo "configure httpd (create /etc/httpd/conf.d/gitlab.conf)"
cat > /etc/httpd/conf.d/gitlab.conf << "EOF"
ProxyPreserveHost On
Proxypass /gitlab http://localhost:6745/gitlab
Proxypassreverse /gitlab http://localhost:6745/gitlab
ProxyRequests     Off
EOF

echo "restart httpd"
systemctl restart httpd.service


myip=`hostname -I`
echo "Now meet you here: http://$myip/gitlab"
