#!/bin/bash

echo "install postfix"
yum -y install postfix
yum -y remove sendmail # make postfix the default MTA
 
echo "start service"
service postfix start

echo "configure postfix"

# comments all:
sed -i "s/^\(inet_interfaces = \)/#\1/" /etc/postfix/main.cf
sed -i "s/^\(mydestination = \)/#\1/" /etc/postfix/main.cf

# remove comments:
sed -i "s/^#\(inet_interfaces = all\)/\1/" /etc/postfix/main.cf
sed -i "s/^#\(home_mailbox = Maildir\/\)/\1/" /etc/postfix/main.cf
sed -i "s/^#\(mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain\)$/\1/" /etc/postfix/main.cf

echo "reload postfix"
service postfix reload

echo "open smtp port (i.e 25)"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 25 -j ACCEPT
service iptables save
service iptables restart
