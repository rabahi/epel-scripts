##################################
#       RSYSLOG
##################################

echo "install rsyslog"
yum -y install rsyslog*

echo "start nfs on startup"
systemctl enable rsyslog.service

echo "configure rsyslog"
mysql --user=root --password=root < /usr/share/doc/rsyslog-*/mysql-createDB.sql

mysql --user=root --password=root -e "CREATE USER 'rsyslog'@'localhost' IDENTIFIED BY 'rsyslog';"
mysql --user=root --password=root -e "use Syslog; GRANT ALL PRIVILEGES ON Syslog.* TO 'rsyslog'@'localhost' WITH GRANT OPTION;"

sed "s/#\(\$ModLoad imudp\)/\1/" /etc/rsyslog.conf
sed "s/#\(\$UDPServerRun 514\)/\1/" /etc/rsyslog.conf

sed "s/#\(\$ModLoad imtcp\)/\1/" /etc/rsyslog.conf
sed "s/#\(\$InputTCPServerRun 514\)/\1/" /etc/rsyslog.conf

cat >> /etc/rsyslog.conf << "EOF"
$ModLoad ommysql
 *.* :ommysql:127.0.0.1,Syslog,rsyslog,rsyslog
EOF

echo "open port 514/tcp and 514 udp"
firewall-cmd --zone=public --add-port=514/tcp
firewall-cmd --zone=public --add-port=514/udp

echo "start service"
systemctl start rsyslog.service


##################################
#       LOG ANALYZER
##################################

echo "download loganalyzer"
wget http://download.adiscon.com/loganalyzer/loganalyzer-4.1.3.tar.gz -O /tmp/loganalyzer-4.1.3.tar.gz

echo "configure loganalyzer"
cd /tmp
tar xvfz loganalyzer-4.1.3.tar.gz

mv loganalyzer-4.1.3/src/* /var/www/html/loganalyzer
touch /var/www/html/loganalyzer/config.php
chown apache:apache /var/www/html/loganalyzer/config.php
chmod 755 /var/www/html/loganalyzer/config.php

touch /var/log/syslog
chown apache:apache /var/log/syslog
chmod 755 /var/log/syslog

myip=`hostname -I`
echo "Now meet you here: http://$myip/loganalyzer"
