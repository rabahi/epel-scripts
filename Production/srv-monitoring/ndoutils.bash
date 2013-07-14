#!/bin/bash

yum -y install ndoutils ndoutils-mysql

echo "update /etc/nagios/ndomod.cfg"
sed -i "s/instance_name=default/instance_name=Central/g" /etc/nagios/ndomod.cfg
sed -i "s/output_type=unixsocket/output_type=unixsocket/g" /etc/nagios/ndomod.cfg
sed -i "s/output=\/var\/run\/ndoutils\/ndoutils.sock/output=\/var\/run\/ndoutils\/ndoutils.sock/g" /etc/nagios/ndomod.cfg
sed -i "s/tcp_port=5668/tcp_port=5668/g" /etc/nagios/ndomod.cfg
sed -i "s/output_buffer_items=5000/output_buffer_items=5000/g" /etc/nagios/ndomod.cfg
sed -i "s/output=\/var\/cache\/ndoutils\/ndomod.buffer/output=\/var\/cache\/ndoutils\/ndomod.buffer/g" /etc/nagios/ndomod.cfg

echo "update /etc/nagios/ndo2db.cfg"
sed -i "s/ndo2db_user=nagios/ndo2db_user=nagios/g" /etc/nagios/ndo2db.cfg
sed -i "s/ndo2db_group=nagios/ndo2db_group=nagios/g" /etc/nagios/ndo2db.cfg

sed -i "s/socket_type=unix/socket_type=unix/g" /etc/nagios/ndo2db.cfg
sed -i "s/socket_name=\/var\/run\/ndoutils\/ndoutils.sock/socket_name=\/var\/run\/ndoutils\/ndoutils.sock/g" /etc/nagios/ndo2db.cfg
sed -i "s/tcp_port=5668/tcp_port=5668/g" /etc/nagios/ndo2db.cfg

sed -i "s/db_servertype=mysql/db_servertype=mysql/g" /etc/nagios/ndo2db.cfg
sed -i "s/db_host=localhost/db_host=localhost/g" /etc/nagios/ndo2db.cfg
sed -i "s/db_port=3306/db_port=3306/g" /etc/nagios/ndo2db.cfg
sed -i "s/db_name=nagios/db_name=centreon_status/g" /etc/nagios/ndo2db.cfg
sed -i "s/db_prefix=nagios_/db_prefix=nagios_/g" /etc/nagios/ndo2db.cfg
sed -i "s/db_user=ndouser/db_user=centreon/g" /etc/nagios/ndo2db.cfg
sed -i "s/db_pass=ndopassword/db_pass=centreon/g" /etc/nagios/ndo2db.cfg

echo "update /etc/nagios/nagios.cfg"
sed -i "s/event_broker_options=-1/event_broker_options=-1/g" /etc/nagios/nagios.cfg
sed -i "s/#broker_module=\/somewhere\/module1.o/broker_module=\/usr\/lib64\/nagios\/brokers\/ndomod.so config_file=\/etc\/nagios\/ndomod.cfg/g" /etc/nagios/nagios.cfg

chown nagios:nagios /etc/nagios/ -R

service ndo2db restart
service nagios restart

