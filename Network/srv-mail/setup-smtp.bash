#!/bin/bash

echo "install postfix"
dnf -y install postfix
dnf -y remove sendmail # make postfix the default MTA
 
echo "start service"
systemctl start postfix.service

echo "configure postfix"

# comments all:
sed -i "s/^\(inet_interfaces = \)/#\1/" /etc/postfix/main.cf
sed -i "s/^\(mydestination = \)/#\1/" /etc/postfix/main.cf

# remove comments:
sed -i "s/^#\(inet_interfaces = all\)/\1/" /etc/postfix/main.cf
sed -i "s/^#\(home_mailbox = Maildir\/\)/\1/" /etc/postfix/main.cf
sed -i "s/^#\(mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain\)$/\1/" /etc/postfix/main.cf

echo "reload postfix"
systemctl reload postfix.service

echo "add service smtp (port 25) to firewall"
firewall-cmd --permanent --add-service smtp
firewall-cmd --reload
