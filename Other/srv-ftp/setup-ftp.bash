#!/bin/bash

echo "install vsftpd"
yum -y install vsftpd

echo "Append firewall rule to open port 21"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
service iptables save
service iptables restart


echo "Configure /etc/vsftpd/vsftpd.conf"
sed -i "s/^\(anonymous_enable=\).*/\1\NO/" /etc/vsftpd/vsftpd.conf
sed -i "s/^\#\(chroot_local_user=YES\).*/\1/" /etc/vsftpd/vsftpd.conf


echo "launch vsftpd at startup"
chkconfig vsftpd on

echo "launch vsftpd"
service vsftpd start

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you there: ftp://$myip"
echo "NOTE: Each user (except root) will be able to connect. They will access by default to their home directory."