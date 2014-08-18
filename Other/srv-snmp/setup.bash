echo "install snmp"
yum -y install net-snmp net-snmp-utils
 
echo "start snmp on startup"
systemctl enable snmpd.service
 
echo "start service"
systemctl start snmpd.service
 
echo "open snmp ports (ports 161 and 162)"
firewall-cmd --permanent --add-port=161/tcp
firewall-cmd --permanent --add-port=162/tcp

