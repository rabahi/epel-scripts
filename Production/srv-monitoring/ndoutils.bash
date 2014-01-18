#!/bin/bash

yum -y install ndoutils ndoutils-mysql

echo "update /etc/nagios/ndomod.cfg"
sed -i "s/^\(instance_name=\).*/\1Central/g" /etc/nagios/ndomod.cfg
sed -i "s/^\(output_type=\).*/\1tcpsocket/g" /etc/nagios/ndomod.cfg
sed -i "s/^\(output=\).*/\1localhost/g" /etc/nagios/ndomod.cfg
sed -i "s/^\(tcp_port=\).*/\15668/g" /etc/nagios/ndomod.cfg
sed -i "s/^\(output_buffer_items=\).*/\15000/g" /etc/nagios/ndomod.cfg

echo "update /etc/nagios/ndo2db.cfg"
ln -s /var/run/ndoutils/ndoutils.sock /var/run/ndo.sock
sed -i "s/^\(ndo2db_user=\).*/\1nagios/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(ndo2db_group=\).*/\1nagios/g" /etc/nagios/ndo2db.cfg

sed -i "s/^\(socket_type=\).*/\1tcp/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(socket_name=\).*/\1\/var\/run\/ndo.sock/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(tcp_port=\).*/\15668/g" /etc/nagios/ndo2db.cfg

sed -i "s/^\(db_servertype=\).*/\1mysql/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(db_host=\).*/\1localhost/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(db_port=\).*/\13306/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(db_name=\).*/\1centreon_status/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(db_prefix=\).*/\1nagios_/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(db_user=\).*/\1centreon/g" /etc/nagios/ndo2db.cfg
sed -i "s/^\(db_pass=\).*/\1centreon/g" /etc/nagios/ndo2db.cfg

echo "update /etc/nagios/nagios.cfg"
sed -i "s/event_broker_options=-1/event_broker_options=-1/g" /etc/nagios/nagios.cfg
sed -i "s/#broker_module=\/somewhere\/module1.o/broker_module=\/usr\/lib64\/nagios\/brokers\/ndomod.so config_file=\/etc\/nagios\/ndomod.cfg/g" /etc/nagios/nagios.cfg

chown nagios:nagios /etc/nagios/ -R

service ndo2db restart
service nagios restart

