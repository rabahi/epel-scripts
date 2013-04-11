#!/bin/bash

echo "install java"
yum -y install java-1.6.0-openjdk

echo "install tomcat"
mkdir -p /opt/java
wget -O /opt/java/apache-tomcat-6.0.36.tar.gz http://mirrors.ircam.fr/pub/apache/tomcat/tomcat-6/v6.0.36/bin/apache-tomcat-6.0.36.tar.gz
cd /opt/java
tar xvfz apache-tomcat-6.0.36.tar.gz

echo "create service /etc/init.d/tomcat6"
cat > /etc/init.d/tomcat6 << "EOF"
#!/bin/bash
# chkconfig: 234 20 80
# description: Tomcat Server basic start/shutdown script
# processname: tomcat6

tomcat=/opt/java/apache-tomcat-6.0.36
startup=$tomcat/bin/startup.sh
shutdown=$tomcat/bin/shutdown.sh

start() {
  echo -n $"Starting Tomcat service: "
  sh $startup
  echo $?
}

stop() {
  echo -n $"Stopping Tomcat service: "
  sh $shutdown
  echo $?
}

restart() {
  stop
  start
}

status() {
  ps -aef | grep apache-tomcat | grep -v tomcat6 | grep -v grep
}

# Handle the different input options
case "$1" in
start)
  start
  ;;
stop)
  stop
  ;;
status)
  status
  ;;
restart)
  restart
  ;;
*)
  echo $"Usage: $0 {start|stop|restart|status}"
  exit 1
esac

exit 0

EOF

chmod a+x /etc/init.d/tomcat6
chkconfig --add tomcat6

echo "launch tomcat6 at startup"
chkconfig tomcat6 on

echo "Append firewall rule to open port 8080"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
service iptables save
service iptables restart

echo "launch tomcat6"
/etc/init.d/tomcat6 start

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you there: http://$myip:8080"