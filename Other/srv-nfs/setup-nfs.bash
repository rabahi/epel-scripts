echo "install nfs tools"
yum -y install nfs-utils nfs-utils-lib
 
echo "start nfs on startup"
chkconfig rpcbind on
chkconfig nfs on
 
echo "start service"
service rpcbind start
service nfs start
 
echo "add right to anonymous user NFS (id 65534)"
mkdir -p /opt/nfs
chown 65534:65534 /opt/nfs
chmod 755 /opt/nfs
 
echo "add rule to enable connection for client 192.168.0.10 (must set ip address)"
cat >> /etc/exports << "EOF"
/opt/nfs           192.168.0.10(rw,sync) 
EOF
 
echo "enable rules"
exportfs -a

echo "Open ports 111,2049,4045"
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 111 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2049 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2049 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 4045 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 4045 -j ACCEPT
service iptables save
service iptables restart