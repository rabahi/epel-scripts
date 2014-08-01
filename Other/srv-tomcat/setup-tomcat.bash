#!/bin/bash

echo "install java"
yum -y install java-1.7.0-openjdk

echo "install tomcat"
mkdir -p /opt/java
wget -O /opt/java/apache-tomcat-6.0.37.tar.gz http://mirrors.ircam.fr/pub/apache/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz
cd /opt/java
tar xvfz apache-tomcat-6.0.37.tar.gz

ln -s /opt/java/apache-tomcat-6.0.37 /opt/java/apache-tomcat

echo "create service /etc/init.d/tomcat6"
cat > /etc/init.d/tomcat6 << "EOF"
#!/bin/bash
# chkconfig: 234 20 80
# description: Tomcat Server basic start/shutdown script
# processname: tomcat6
# pidfile: /opt/java/apache-tomcat/temp/pid

. /etc/rc.d/init.d/functions

# Set Tomcat environment.
USER=root
export PROCESSNAME=tomcat6
export BASEDIR=/opt/java/apache-tomcat
export CATALINA_HOME=$BASEDIR
export CATALINA_BASE=$BASEDIR
export CATALINA_PID=$BASEDIR/temp/pid
export CATALINA_OPTS="-Xmx512m -Djava.awt.headless=true"
LOCKFILE=$BASEDIR/temp/lockfile

case "$1" in
  start)
        echo -n "Starting service $PROCESSNAME: "
        status -p $CATALINA_PID $PROCESSNAME > /dev/null && failure || (su -p -s /bin/sh $USER -c "cd $CATALINA_HOME && $CATALINA_HOME/bin/catalina.sh start" > /dev/null && (touch $LOCKFILE ; success))
        echo
        ;;
  stop)
        echo -n "Shutting down service $PROCESSNAME: "
        status -p $CATALINA_PID $PROCESSNAME > /dev/null && su -p -s /bin/sh $USER -c "cd $CATALINA_HOME && $CATALINA_HOME/bin/catalina.sh stop" > /dev/null && (rm -f $LOCKFILE ; success) || failure
        echo
        ;;
  restart)
        $0 stop
        $0 start
        ;;
  condrestart)
       [ -e $LOCKFILE ] && $0 restart
       ;;
  status)
        status -p $CATALINA_PID $PROCESSNAME
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|condrestart|status}"
        exit 1
        ;;
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
