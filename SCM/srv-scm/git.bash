#!/bin/bash
 
echo "install tools git gitweb git-daemon"
dnf -y install git gitweb git-daemon
 
echo "create trees in /opt/git"
mkdir -p /opt/git/cgi-bin
mkdir -p /opt/git/repos
mkdir -p /opt/git/bin
mkdir -p /opt/git/conf
 
echo "create /opt/git/conf/gitweb.conf"
cat > /opt/git/conf/gitweb.conf << "EOF"
$projectroot='/opt/git/repos/';
$site_name="My git trees";
$my_uri="/";
@stylesheets = ("/gitweb.css");
$favicon = "/git-favicon.png";
$logo = "/git-logo.png";
EOF
 
 
 
 
echo "copy gitweb.cgi to /opt/git/cgi-bin and update script var \$projectroot"
_oldpath="/var/lib/git"
_newpath="/opt/git/repos"
 
#Escape char for sed:
_oldpath="${_oldpath//\//\\/}"
_newpath="${_newpath//\//\\/}"
 
#replace
echo oldpath : ${_oldpath} 
sed -e "s/${_oldpath}/${_newpath}/g" /var/www/git/gitweb.cgi > /opt/git/cgi-bin/gitweb.cgi
 
chmod a+x /opt/git/cgi-bin/gitweb.cgi
 
 
 
 
echo "copy gitweb requistes to /var/www/html"
cp /var/www/git/*.png /var/www/html
cp /var/www/git/*.css /var/www/html
cp /var/www/git/*.js  /var/www/html
 
echo "configure httpd (create /etc/httpd/conf.d/git.conf)"
cat > /etc/httpd/conf.d/git.conf << "EOF"
 ScriptAliasMatch ^/git/(.*)$ /opt/git/cgi-bin/gitweb.cgi/$1
 <Directory "/opt/git/cgi-bin/">
   SetHandler cgi-script
   AllowOverride All
   Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
   Require all granted
  </Directory>
  ErrorLog /var/log/httpd/git-error.log
  CustomLog /var/log/httpd/git-access.log common
 
<Location /git/>
   # Load git mod
   DAV On
   Options ExecCGI FollowSymLinks Indexes
   Require all granted
</Location>
EOF
 
echo "create symbolic link for the repo"
ln -s /opt/git/repos /var/www/html/git
 
echo "create /opt/git/bin/create.sh"
cat > /opt/git/bin/create.sh << "EOF"
git init --bare /opt/git/repos/$1.git
 
#update repos:
cd /opt/git/repos/$1.git
cp hooks/post-update.sample hooks/post-update
chmod +x hooks/post-update
git update-server-info
cd -
 
#owner and mod
chown -R apache:apache /opt/git/repos/$1.git
chmod -R 750 /opt/git/repos/$1.git
 
EOF
chmod a+x /opt/git/bin/create.sh
 
echo "create a sample repository named 'myrepos'"
/opt/git/bin/create.sh myrepos
 
echo "Now restart httpd"
systemctl restart httpd.service
 
myip=`hostname -I`
echo "Now meet you here: http://$myip/git/"
