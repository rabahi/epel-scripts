#!/bin/bash

echo "install dovecot"
yum -y install dovecot

echo "configure dovecot"
sed -i "s/^#\(protocols\s*=\)/\1/" /etc/dovecot/dovecot.conf

echo "start service dovecot on boot"
systemctl enable dovecot.service

echo "start service"
systemctl start dovecot.service


echo "open pop3 port (i.e 110) and imap (i.e. 143)"
firewall-cmd --permanent --add-service dovecot