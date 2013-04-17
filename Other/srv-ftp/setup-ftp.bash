#!/bin/bash

echo "install vsftpd"
yum -y install vsftpd pam_mysql

echo "Append firewall rule to open port 21"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
service iptables save
service iptables restart

echo "create database vsftpd, user/password vsftpd/vsftpd":
mysql --user=root --password=root -e "CREATE USER 'vsftpd'@'localhost' IDENTIFIED BY 'vsftpd';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS vsftpd;"
mysql --user=root --password=root -e "use vsftpd; GRANT ALL PRIVILEGES ON vsftpd.* TO 'vsftpd'@'localhost' WITH GRANT OPTION;"

echo "initialize vsftpd table"
mysql --user=root --password=root -e 'use vsftpd; CREATE TABLE IF NOT EXISTS `vsftpd`.`users` (`id_user` int(11) NOT NULL auto_increment,`login` varchar(50) NOT NULL,`password` varchar(100) NOT NULL,`active` int(11) NOT NULL,PRIMARY KEY  (`id_user`)) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;'
mysql --user=root --password=root -e 'use vsftpd; CREATE TABLE IF NOT EXISTS `vsftpd`.`log` (`id_log` int(11) NOT NULL auto_increment,`login` varchar(50) NOT NULL,`message` varchar(200) NOT NULL,`pid` varchar(10) NOT NULL,`host` varchar(30) NOT NULL,`time` datetime default NULL,PRIMARY KEY  (`id_log`)) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;'

echo "Configure /etc/vsftpd/vsftpd.conf"
cat > /etc/vsftpd/vsftpd.conf << "EOF"
# Listen port
listen_port=21

# You may fully customise the login banner string:
ftpd_banner=Welcome to blah FTP service.

# PAM configuration file
pam_service_name=vsftpd

# When "listen" directive is enabled, vsftpd runs in standalone mode and
# listens on IPv4 sockets. This directive cannot be used in conjunction
# with the listen_ipv6 directive.
listen=YES

# Allow anonymous FTP? (Beware - allowed by default if you comment this out).
anonymous_enable=NO
anon_world_readable_only=NO
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO

# Uncomment this to allow local users to log in.
local_enable=YES

# Userlist file
userlist_file=/etc/vsftpd/user_list
userlist_enable=YES
userlist_deny=YES

# Uncomment this to enable any form of FTP write command.
write_enable=NO

# Allow un-anonymous guest users to connect to ftp (map to ftpsecure)
guest_enable=YES
guest_username=ftpsecure

# You may specify an explicit list of local users to chroot() to their home
# directory. If chroot_local_user is YES, then this list becomes a list of
# users to NOT chroot().
chroot_local_user=YES

# Maximum number of simultaneous connection
max_clients=50

# Maximum number of connections from the same IP
max_per_ip=1

# Record specific user configuration
user_config_dir=/etc/vsftpd/vsftpd_user_conf

# The target log file can be vsftpd_log_file or xferlog_file.
# This depends on setting xferlog_std_format parameter
xferlog_enable=YES
EOF
chmod 600 /etc/vsftpd/vsftpd.conf

echo "Add non-privileged user ftpsecure"
useradd -G users -s /sbin/nologin -d /home/ftpsecure  ftpsecure

echo "configure pam_mysql"
cat > /etc/pam.d/vsftpd << "EOF"
#%PAM-1.0
auth sufficient pam_unix.so
account sufficient pam_unix.so
auth required /lib64/security/pam_mysql.so verbose=0 user=vsftpd passwd=vsftpd host=127.0.0.1 db=vsftpd table=users usercolumn=login passwdcolumn=password crypt=3 where=users.active=1 sqllog=yes logtable=log logmsgcolumn=message logusercolumn=login logpidcolumn=pid loghostcolumn=host logtimecolumn=time
account required /lib64/security/pam_mysql.so verbose=0 user=vsftpd passwd=vsftpd host=127.0.0.1 db=vsftpd table=users usercolumn=login passwdcolumn=password crypt=3 where=users.active=1 sqllog=yes logtable=log logmsgcolumn=message logusercolumn=login logpidcolumn=pid loghostcolumn=host logtimecolumn=time
EOF


echo "create /etc/vsftpd/vsftpd_user_conf directory"
mkdir -p /etc/vsftpd/vsftpd_user_conf

echo "create new user myuser/mypassword (i.e. user/password)"
mysql --user=root --password=root -e 'use vsftpd; INSERT INTO `vsftpd`.`users` (`id_user`, `login`, `password`, `active`) VALUES (NULL, 'myuser', MD5('mypassword'), '1');'

mkdir -p mkdir /home/ftpsecure/myuser
chown ftpsecure:users /home/ftpsecure/myuser -R
chmod 700 /home/ftpsecure/myuser -R

cat > /etc/vsftpd/vsftpd_user_conf/myuser << "EOF"
local_root=myuser
write_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
EOF

echo "launch vsftpd at startup"
chkconfig vsftpd on

echo "launch vsftpd"
service vsftpd start

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you there: ftp://$myip"
echo "NOTE: try to connect using login/password : myuser/mypassword"