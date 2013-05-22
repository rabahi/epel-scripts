#!/bin/bash

echo "install openldap"
yum -y install openldap-servers openldap-clients phpldapadmin

echo "start service slapd at boot"
chkconfig slapd on

echo "Append firewall rule to open port 389"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 389 -j ACCEPT
service iptables save
service iptables restart
 
echo "configure ldap"
rm -f /var/lib/ldap/DB_CONFIG
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap:ldap /var/lib/ldap

#create rootdn password
myRootDnPassword=`slappasswd -s root`

sed -i "s/dc=my-domain,dc=com/dc=my-domain,dc=local/g" /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif
echo olcRootPW: $myRootDnPassword  >> /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif

sed -i "s/dc=my-domain,dc=com/dc=my-domain,dc=local/g" /etc/openldap/slapd.d/cn\=config/olcDatabase={1}monitor.ldif

echo "quick tests"
echo URI ldap://127.0.0.1 >> /etc/openldap/ldap.conf
echo BASE dc=my-domain,dc=local >> /etc/openldap/ldap.conf

ldapsearch -x  -b "dc=my-domain,dc=local"

cat > /etc/openldap/schema/base.ldif << "EOF"
dn: dc=my-domain,dc=local
dc: my-domain
objectClass: top
objectClass: domain

dn: ou=People,dc=my-domain,dc=local
ou: People
objectClass: top
objectClass: organizationalUnit

dn: ou=Group,dc=my-domain,dc=local
ou: Group
objectClass: top
objectClass: organizationalUnit 
EOF


cat > /etc/openldap/schema/group.ldif << "EOF"
dn: cn=myuser,ou=Group,dc=my-domain,dc=local
objectClass: posixGroup
objectClass: top
cn: myuser
userPassword: password
gidNumber: 1000 
EOF

cat > /etc/openldap/schema/people.ldif << "EOF"
dn: uid=myuser,ou=People,dc=my-domain,dc=local
uid: myuser
cn: myuser myuser
objectClass: account
objectClass: posixAccount
objectClass: top
objectClass: shadowAccount
userPassword: password
shadowLastChange: 15140
shadowMin: 0
shadowMax: 99999
shadowWarning: 7
loginShell: /bin/bash
uidNumber: 1000
gidNumber: 1000
homeDirectory: /home/myuser 
EOF

#Import files to LDAP
ldapadd -x -w root -D "cn=Manager,dc=my-domain,dc=local" -f /etc/openldap/schema/base.ldif
ldapadd -x -w root -D "cn=Manager,dc=my-domain,dc=local" -f /etc/openldap/schema/group.ldif
ldapadd -x -w root -D "cn=Manager,dc=my-domain,dc=local" -f /etc/openldap/schema/people.ldif

#Quick test
ldapsearch -x  -b "dc=my-domain,dc=local"

echo "start service"
service slapd start


echo "Note: by default only local users can access to phpldapadmin."
echo "Let's update the file /etc/httpd/conf.d/phpldapadmin.conf and allow everyone."
sed -i "s/\(Deny\s*from\s*All\)/#\1/i" /etc/httpd/conf.d/phpldapadmin.conf
sed -i "s/\(Allow\s*from\s*127.0.0.1\)/#\1/i" /etc/httpd/conf.d/phpldapadmin.conf
sed -i "s/\(Allow\s*from\s*::1\)/#\1/i" /etc/httpd/conf.d/phpldapadmin.conf

echo "restart httpd"
service httpd restart