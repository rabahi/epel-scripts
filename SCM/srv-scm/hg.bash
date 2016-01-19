#!/bin/bash
 
echo "install tools mercurial, mod_wsgi"
yum -y install mercurial mod_wsgi
 
echo "create trees in /opt/hg"
mkdir -p /opt/hg/cgi-bin
mkdir -p /opt/hg/repos
mkdir -p /opt/hg/bin
 
echo "copy hgweb.cgi to /opt/hg/cgi-bin"
cp /usr/share/doc/mercurial-2.6.2/hgweb.cgi /opt/hg/cgi-bin
chmod a+x /opt/hg/cgi-bin/hgweb.cgi
 
echo "create file /opt/hg/cgi-bin/hgweb.config"
cat > /opt/hg/cgi-bin/hgweb.config << "EOF"
[collections]
/opt/hg/repos = /opt/hg/repos
 
[web]
style = monoblue
allow_push = *
push_ssl = false
encoding = UTF-8
EOF
 
echo "configure httpd (create /etc/httpd/conf.d/hg.conf)"
cat > /etc/httpd/conf.d/hg.conf << "EOF"
 ScriptAliasMatch ^/hg(.*)$ /opt/hg/cgi-bin/hgweb.cgi/$1
 
 <Directory "/opt/hg/cgi-bin/">
   SetHandler cgi-script
   AllowOverride All
   Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
   Order allow,deny
   Allow from all
  </Directory>
  ErrorLog /var/log/httpd/hg-error.log
  CustomLog /var/log/httpd/hg-access.log common
EOF

echo "set selinux permissions. can check permission by using 'ls -alZ /opt/cgi-bin/hgweb.cgi"
chcon --type=httpd_sys_rw_content_t /opt/cgi-bin/hgweb.cgi

echo "create /opt/hg/bin/create.sh"
cat > /opt/hg/bin/create.sh << "EOF"
hg init /opt/hg/repos/$1
chown -R apache:apache /opt/hg/repos/$1
chmod -R 750 /opt/hg/repos/$1
EOF
chmod a+x /opt/hg/bin/create.sh
 
echo "create a sample repository named 'myrepos'"
/opt/hg/bin/create.sh myrepos
 
echo "Now restart httpd"
systemctl restart httpd.service
 
myip=`hostname -I`
echo "Now meet you there: http://$myip/hg"
