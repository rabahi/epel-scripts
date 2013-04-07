#!/bin/bash
 
echo "install tools subversion, mod_dav_svn"
yum -y install subversion mod_dav_svn
 
echo "create trees in /opt/svn"
mkdir -p /opt/svn/repos
mkdir -p /opt/svn/bin
mkdir -p /opt/svn/conf
 
echo "create sample of svn access file (/opt/svn/conf/dav_svn.authz)"
cat > /opt/svn/conf/dav_svn.authz << "EOF"
[groups]
staff = joe, george
 
[/]
* = rw
 
[framework:/]
john =  r
@staff = rw
EOF
 
 
echo "configure httpd (create /etc/httpd/conf.d/svn.conf)"
cat > /etc/httpd/conf.d/svn.conf << "EOF"
LoadModule dav_svn_module     modules/mod_dav_svn.so
LoadModule authz_svn_module   modules/mod_authz_svn.so
 
<Location /svn/>
   # Load subversion mod
   DAV svn
 
   # Subversion configuration
   SVNParentPath /opt/svn/repos
   SVNListParentPath On
   SVNIndexXSLT "/svnindex.xsl"
 
   Options Indexes MultiViews IncludesNoExec
 
   AuthzSVNAccessFile /opt/svn/conf/dav_svn.authz
   AuthType Basic
   AuthName "Subversion repos"
   Order allow,deny
   Allow from all
</Location>
EOF
 
echo "get svnindex file from here: http://code.google.com/p/tortoisesvn/source/browse/trunk/contrib/svnindex/"
wget http://tortoisesvn.googlecode.com/svn/trunk/contrib/svnindex/menucheckout.ico -O /var/www/html/menucheckout.ico
wget http://tortoisesvn.googlecode.com/svn/trunk/contrib/svnindex/svnindex.xsl -O /var/www/html/svnindex.xsl
wget http://tortoisesvn.googlecode.com/svn/trunk/contrib/svnindex/svnindex.css -O /var/www/html/svnindex.css
chown apache:apache /var/www/html/ -R
 
echo "create /opt/svn/bin/create.sh"
cat > /opt/svn/bin/create.sh << "EOF"
svnadmin create /opt/svn/repos/$1
chown -R apache:apache /opt/svn/repos/$1
chmod -R 750 /opt/svn/repos/$1
EOF
chmod a+x /opt/svn/bin/create.sh
 
echo "create a sample repository named 'myrepos'"
/opt/svn/bin/create.sh myrepos
 
echo "set authz on /opt/svn"
chown apache:apache /opt/svn/ -R
 
echo "Now restart httpd"
/etc/init.d/httpd restart
 
myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you there: http://$myip/svn/"
