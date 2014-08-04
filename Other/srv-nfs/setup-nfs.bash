echo "install nfs tools"
yum -y install nfs-utils nfs-utils-lib
 
echo "start nfs on startup"
systemctl enable rpcbind.service
systemctl enable nfs.service
 
echo "start service"
systemctl start rpcbind.service
systemctl start nfs.service
 
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

echo "add service nfs (ports 111,2049,4045) to firewall"
firewall-cmd --permanent --add-service nfs
