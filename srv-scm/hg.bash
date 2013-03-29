#!/bin/bash
 
echo "install tools mercurial, mod_wsgi"
yum -y install mercurial.x86_64 mod_wsgi.x86_64
 
echo "create trees in /opt/hg"
mkdir -p /opt/hg/cgi-bin
mkdir -p /opt/hg/repos
mkdir -p /opt/hg/bin
 
echo "copy hgwebdir.cgi to /opt/hg/cgi-bin"
cp /usr/share/doc/mercurial-1.4/hgwebdir.cgi /opt/hg/cgi-bin
chmod a+x /opt/hg/cgi-bin/hgwebdir.cgi
 
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
 ScriptAliasMatch ^/hg(.*)$ /opt/hg/cgi-bin/hgwebdir.cgi/$1
 
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
/etc/init.d/httpd restart
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you there: http://$myip/hg"
