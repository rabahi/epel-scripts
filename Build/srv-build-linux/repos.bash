#!/bin/bash

##################################################
#               DEFINES
##################################################
REPOSITORY_PATH=/var/www/html/rpm


##################################################
#            CREATE REPOSITORY
##################################################

echo "install createrepo repoview"
yum -y install createrepo repoview

echo "create repo file"
mkdir -p $REPOSITORY_PATH
cat > /var/www/html/rpm/myrepo.repo << "EOF"
[myrepo]
name=CentOS-$releasever - Base
baseurl=url:192.168.184.132/rpm/$releasever/$basearch/
gpgcheck=0
enabled=1
protect=1
EOF


echo "create repository"
mkdir -p $REPOSITORY_PATH/centos/7/x86_64

echo "create script to update repo"
mkdir -p /opt/rpm/scripts
cat > /opt/rpm/scripts/autoupdate.sh << "EOF"
#!/bin/bash

chown -R apache:apache /var/www/html/rpm/ -R
createrepo --unique-md-filenames --checksum sha -d /var/www/html/rpm/centos/7/x86_64
repoview /var/www/html/rpm/centos/7/x86_64
EOF

echo "add autoupdate script to crontab"
if ! grep -q RPM /etc/crontab; then
echo "" >> /etc/crontab
echo "######## RPM #######" >> /etc/crontab
echo "every 1 minutes" >> /etc/crontab
echo "*/1 * * * * root chmod a+x /opt/rpm/scripts/autoupdate.sh; /opt/rpm/scripts/autoupdate.sh" >> /etc/crontab
echo "######## RPM #######" >> /etc/crontab
fi


##################################################
#            CONFIGURE HTTPD
##################################################

echo "create /etc/httpd/conf.d/repo.conf"
cat > /etc/httpd/conf.d/repo.conf << "EOF"
<Directory /var/www/html/>
    Options Indexes
    Options Indexes FollowSymLinks
    Require all granted
</Directory>
EOF

echo "restart httpd"
systemctl restart httpd.service

##################################################
#            SIGN REPOSITORY
##################################################
# echo "sign repository"
# gpg --gen-key
# gpg --detach-sign --armor $REPOSITORY_PATH/centos/7/x86_64/repodata/repomd.xml


myip=`hostname -I`
echo "Now meet you here: http://$myip/rpm/centos/7/x86_64/repoview/index.html"
