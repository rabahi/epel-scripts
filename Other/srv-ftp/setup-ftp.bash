#!/bin/bash

echo "install vsftpd"
yum -y install vsftpd pam_mysql

echo "Append firewall rule to open port 21"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
service iptables save
sed -i "s/\(IPTABLES_MODULES=\)/\1\"ip_conntrack_ftp\"/i" /etc/sysconfig/iptables-config
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
# Note, if you set value to 1, you won't be able to upload / download files (because it will create a new connection)
max_per_ip=10

# Record specific user configuration
user_config_dir=/etc/vsftpd/vsftpd_user_conf

# The target log file can be vsftpd_log_file or xferlog_file.
# This depends on setting xferlog_std_format parameter
xferlog_enable=YES

# PASV - passive ports for FTP (range 44000 - 44100 ; 100 PASV ports, OPEN FIREWALL FOR ALLOWING CONNECTIONS
pasv_enable=YES
pasv_min_port=44000
pasv_max_port=44100
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

echo "generate script to create new user"
mkdir -p /opt/vsftpd/scripts
cat > /opt/vsftpd/scripts/user_create.bash << "EOF"
#!/bin/bash

EXPECTED_ARGS=2

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {user} {password}"
  exit 1
fi

user=$1
password=$2

echo "create new user $user/$password (i.e. user/password)"
mysql --user=root --password=root -e 'use vsftpd; INSERT INTO `vsftpd`.`users` (`id_user`, `login`, `password`, `active`) VALUES (NULL, "'$user'", MD5("'$password'"), 1);'

mkdir -p mkdir /home/ftpsecure/$user
chown ftpsecure:users /home/ftpsecure/$user -R
chmod 700 /home/ftpsecure/$user -R

# configuration file
echo "local_root=$user" > /etc/vsftpd/vsftpd_user_conf/$user
echo "write_enable=YES" >> /etc/vsftpd/vsftpd_user_conf/$user
echo "anon_upload_enable=YES" >> /etc/vsftpd/vsftpd_user_conf/$user
echo "anon_mkdir_write_enable=YES" >> /etc/vsftpd/vsftpd_user_conf/$user
echo "anon_other_write_enable=YES" >> /etc/vsftpd/vsftpd_user_conf/$user

EOF


cat > /opt/vsftpd/scripts/user_disable.bash << "EOF"
#!/bin/bash

EXPECTED_ARGS=1

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {user}"
  exit 1
fi

user=$1

mysql --user=root --password=root -e 'use vsftpd; UPDATE `vsftpd`.`users` SET `active` = '0' WHERE `users`.`login` ="'$user'";'
EOF

cat > /opt/vsftpd/scripts/user_enable.bash << "EOF"
#!/bin/bash

EXPECTED_ARGS=1

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {user}"
  exit 1
fi

user=$1

mysql --user=root --password=root -e 'use vsftpd; UPDATE `vsftpd`.`users` SET `active` = '1' WHERE `users`.`login` ="'$user'";'
EOF

cat > /opt/vsftpd/scripts/user_delete.bash << "EOF"
#!/bin/bash

EXPECTED_ARGS=1

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {user}"
  exit 1
fi

user=$1

mysql --user=root --password=root -e 'use vsftpd; DELETE FROM `vsftpd`.`users` WHERE `users`.`id_user` = "'$user'"'

rm -f /etc/vsftpd/vsftpd_user_conf/$user
rm -fr /home/ftpsecure/$user
EOF

echo "create /etc/vsftpd/vsftpd_user_conf directory"
mkdir -p /etc/vsftpd/vsftpd_user_conf

echo "create new user myuser/mypassword (i.e. user/password)"
bash /opt/vsftpd/scripts/user_create.bash myuser mypassword

echo "launch vsftpd at startup"
chkconfig vsftpd on

echo "launch vsftpd"
service vsftpd start

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you there: ftp://$myip"
echo "NOTE: try to connect using login/password : myuser/mypassword"