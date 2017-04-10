#!/bin/bash

##################################################
#               DEFINES
##################################################

# Nothing

##################################################
#               PREREQUISTES
##################################################

echo "install openldap"
dnf -y install openldap-servers openldap-clients phpldapadmin


##################################################
#               CONFIGURE SERVICE
##################################################

echo "enable service slapd on boot"
systemctl enable slapd.service

echo "add service slap (port 389) to firewall"
firewall-cmd --permanent --add-service=ldap
firewall-cmd --reload

echo "start service slapd"
systemctl start slapd.service

##################################################
#               CONFIGURE PHPLDAPADMIN
##################################################

echo "Note: by default only local users can access to phpldapadmin."
echo "Let's update the file /etc/httpd/conf.d/phpldapadmin.conf and allow everyone."
sed -i "s/\(Require\s*local\)/Require all granted/i" /etc/httpd/conf.d/phpldapadmin.conf

echo "restart httpd"
systemctl restart httpd.service