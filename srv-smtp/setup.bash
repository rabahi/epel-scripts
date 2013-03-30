#!/bin/bash

echo "install sendmail"
yum -y install sendmail postfix
 
echo "start service"
service sendmail start

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
