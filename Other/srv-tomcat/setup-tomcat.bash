#!/bin/bash

echo "install java"
dnf -y install java-1.8.0-openjdk

echo "install tomcat"
mkdir -p /opt/java
wget -O /opt/java/apache-tomcat-8.5.13.tar.gz http://apache.crihan.fr/dist/tomcat/tomcat-8/v8.5.13/bin/apache-tomcat-8.5.13.tar.gz
cd /opt/java
tar xvfz apache-tomcat-8.5.13.tar.gz

ln -s /opt/java/apache-tomcat-8.5.13 /opt/java/apache-tomcat

echo "create service /etc/init.d/tomcat"
cat > /etc/init.d/tomcat << "EOF"
#!/bin/bash
# chkconfig: 234 20 80
# description: Tomcat Server basic start/shutdown script
# processname: tomcat
# pidfile: /opt/java/apache-tomcat/temp/pid

. /etc/rc.d/init.d/functions

# Set Tomcat environment.
USER=root
export PROCESSNAME=tomcat
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

chmod a+x /etc/init.d/tomcat
chkconfig --add tomcat

echo "launch tomcat service at startup"
systemctl enable tomcat.service

echo "add service tomcat (port 8080) to firewall"
firewall-cmd --permanent --add-service tomcat

echo "launch tomcat"
systemctl start tomcat

myip=`hostname -I`
echo "Now meet you there: http://$myip:8080"
