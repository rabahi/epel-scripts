#!/bin/bash
 
echo "install package"
yum -y install rrdtool-perl sudo php-pear* net-snmp php-ldap ndoutils*
 
echo "create user/group centreon/centreon"
groupadd centreon
useradd -g centreon centreon
 
echo "download archive"
cd /tmp
wget http://download.centreon.com/index.php?id=4298
 
echo "unpack archive"
tar xvfz centreon-2.4.5.tar.gz
 
echo "install centreon"
cd centreon-2.4.5
export PATH="$PATH:/usr/sbin"
chmod a+x install.sh
 
echo "create response file"
cat > /tmp/centreon-2.4.5/response << "EOF"
## CentWeb: Web front Centreon for Nagios
PROCESS_CENTREON_WWW=1
## CentStorage: Log and charts archiving.
PROCESS_CENTSTORAGE=1
## CentCore: Distributed Monitoring engine.
PROCESS_CENTCORE=1
## CentPlugins: Centreon Plugins for nagios
PROCESS_CENTREON_PLUGINS=1
## CentTraps: Centreon Snmp traps process for nagios
PROCESS_CENTREON_SNMP_TRAPS=1
 
#####################################################################
## Begin: Default variables
#####################################################################
## Your default variables
## $BASE_DIR is the centreon source directory
LOG_DIR="$BASE_DIR/log"
LOG_FILE="$LOG_DIR/install_centreon.log"
 
## Don't change values above unless you perfectly understand
## what you are doing.
## Centreon temporary directory to work
TMP_DIR="/tmp/centreon-setup"
## default snmp config directory
SNMP_ETC="/etc/snmp/"
## a list of pear modules require by Centreon
PEAR_MODULES_LIST="pear.lst"
## Path for PEAR.php file
PEAR_PATH="/usr/share/pear/"
#####################################################################
## End: Default variables
##################################################################
 
 
#####################################################################
## Begin: Centreon preferences
#####################################################################
## Above variables are necessary to run a silent install
## Where you want to install Centreon (Centreon root directory)
INSTALL_DIR_CENTREON="/usr/local/centreon"
## Centreon log files directory
CENTREON_LOG="/usr/local/centreon/log"
## Centreon config files
CENTREON_ETC="/etc/centreon"
## Where is your Centreon binaries directory ?
CENTREON_BINDIR="/usr/local/centreon/bin"
## Where is your Centreon data informations directory ?
CENTREON_DATADIR="/usr/local/centreon/data"
## Centreon generation config directory
##  filesGeneration and filesUpload
## Where is your Centreon generation_files directory ?
CENTREON_GENDIR="/usr/local/centreon"
## libraries temporary files directory
## Where is your Centreon variable library directory ?
CENTREON_VARLIB="/var/lib/centreon"
## Where is your CentPlugins Traps binary?
CENTPLUGINSTRAPS_BINDIR="/usr/local/centreon/bin"
## Where is the RRD perl module installed [RRDs.pm]
## ATTENTION: ON x64 SYSTEMS THE PATH IS LIB64 INSTEAD OF LIB
##               vv
RRD_PERL="/usr/lib64/perl5"
## What is the Centreon group ?
CENTREON_GROUP="centreon"
## What is the Centreon user ?
CENTREON_USER="centreon"
## What is the Monitoring engine user ?
MONITORINGENGINE_USER="nagios"
## What is the Monitoring engine group ?
MONITORINGENGINE_GROUP="nagios"
## What is the Monitoring engine log directory ?
MONITORINGENGINE_LOG="/var/log/nagios"
## Where is your monitoring plugins (libexec) directory ?
PLUGIN_DIR="/usr/lib64/nagios/plugins"
## Path to sudoers file (optional)
## Where is sudo configuration file
SUDO_FILE="/etc/sudoers"
## What is the Monitoring engine init.d script ?
MONITORINGENGINE_INIT_SCRIPT="/etc/init.d/nagios"
## What is the Monitoring engine binary ?
MONITORINGENGINE_BINARY="/usr/sbin/nagios"
## What is the Monitoring engine configuration directory ?
MONITORINGENGINE_ETC="/etc/nagios/"
## Where is the configuration directory for broker module ?
BROKER_ETC="/etc/nagios/"
## Where is the init script for broker module daemon ?
BROKER_INIT_SCRIPT="/etc/init.d/ndo2db"
## Do you want me to configure your sudo ? (WARNING)
FORCE_SUDO_CONF=1
 
#####################################################################
## Begin: Apache preferences
#####################################################################
## Apache configuration directory (optional)
#DIR_APACHE="/etc/apache"
## Apache local specific configuration directory (optional)
## Do you want to update Centreon Apache sub configuration file ?
# DIR_APACHE_CONF="/etc/apache/conf.d"
## Apache configuration file. Only file name. (optional)
#APACHE_CONF="apache.conf"
## Apache user (optional)
WEB_USER="apache"
## Apache group (optional)
WEB_GROUP="apache"
## Force apache reload (optional): set APACHE_RELOAD to 1
## Do you want to reload your Apache ?
APACHE_RELOAD=1
#####################################################################
## End: Apache preferences
#####################################################################
 
 
## Do you want me to install/upgrade your PEAR modules
PEAR_AUTOINST=1
## Centreon run dir (all .pid, .run, .lock)
## Where is your Centreon Run Dir directory?
CENTREON_RUNDIR="/var/run/centreon"
 
## path to centstorage binary
## Where is your CentStorage binary directory
CENTSTORAGE_BINDIR="/usr/local/centreon/bin"
## CentStorage RRDs directory (where .rrd files go)
## Where is your CentStorage RRD directory
CENTSTORAGE_RRD="/var/lib/centreon"
## Do you want me to install CentStorage init script ?
CENTSTORAGE_INSTALL_INIT=1
## Do you want me to install CentStorage run level ?
CENTSTORAGE_INSTALL_RUNLVL=1
 
 
## path to centcore binary
CENTCORE_BINDIR="usr/local/centreon/bin"
## force install init script (install in init.d)
## Set to "1" to enable
## Do you want me to install CentCore init script ?
CENTCORE_INSTALL_INIT=1
## force install run level for init script (add all link on rcX.d)
## Set to "1" to enable
## Do you want me to install CentCore run level
CENTCORE_INSTALL_RUNLVL=1
 
## Some plugins require temporary datas to process output.
## These temp datas are store in the CENTPLUGINS_TMP path.
## Where is your CentPlugins lib directory
CENTPLUGINS_TMP="/var/lib/centreon/centplugins"
 
## path for snmptt installation
SNMPTT_BINDIR="/usr/local/centreon/bin/"
## What is the Broker user ? (optional)
BROKER_USER=$MONITORINGENGINE_USER
 
## Nagios user (optional)
NAGIOS_USER="nagios"
## Nagios group (optional)
NAGIOS_GROUP="nagios"
## Centreon Connector PATH
## Mail (optional)
BIN_MAIL="/bin/mail"
## 
EOF
 
 
# install centreon and use the response file.
./install.sh -f ./response
 
echo "create user/password centreon/centreon and apply grant to databases":
mysql --user=root --password=root -e "CREATE USER 'centreon'@'localhost' IDENTIFIED BY 'centreon';"
mysql --user=root --password=root -e "use centreon; GRANT ALL PRIVILEGES ON centreon.* TO 'centreon'@'localhost' WITH GRANT OPTION;"
mysql --user=root --password=root -e "use centreon_storage; GRANT ALL PRIVILEGES ON centreon_storage.* TO 'centreon'@'localhost' WITH GRANT OPTION;"
mysql --user=root --password=root -e "use centreon_status; GRANT ALL PRIVILEGES ON centreon_status.* TO 'centreon'@'localhost' WITH GRANT OPTION;"

echo "drop previous database (note dangerous!)"
mysql --user=root --password=root -e "DROP DATABASE 'centreon';"
mysql --user=root --password=root -e "DROP DATABASE 'centreon_status';"
mysql --user=root --password=root -e "DROP DATABASE 'centreon_storage';"

echo "centreon wizard silent installation"
cat > /usr/local/centreon/www/install/silent-install.php << "EOF"
<?php

error_reporting(E_ALL);

function postToUrl($url, $data=array())
{
  $myvars = http_build_query($data);
  
  $ch = curl_init();
  
  // Configuration:
  curl_setopt( $ch, CURLOPT_URL, $url);
  curl_setopt( $ch, CURLOPT_POST, 1);
  curl_setopt( $ch, CURLOPT_POSTFIELDS, $myvars);
  curl_setopt( $ch, CURLOPT_FOLLOWLOCATION, 1);
  curl_setopt( $ch, CURLOPT_HEADER, 0);
  curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1);
  
  curl_setopt ($ch, CURLOPT_COOKIEJAR, COOKIE_FILE); 
  curl_setopt ($ch, CURLOPT_COOKIEFILE, COOKIE_FILE); 

  if( ! $result = curl_exec($ch))
  {
      trigger_error(curl_error($ch));
  }
  
  curl_close($ch);  
  return $result;
}

function urlExists($url)
{
  $file_headers = @get_headers($url);
  return strcmp($file_headers[0],'HTTP/1.1 404 Not Found')!=0;
}

function doUrl($url, $step, $title, $data=array())
{
  echo "\n";
  echo "<tr>\n";
  echo " <th>$step - $title</th>\n";
  $response=postToUrl($url, $data);
  echo " <th>$response</th>\n";
  echo "</tr>\n";
}

function step($step, $title, $data=array())
{
  doUrl("http://localhost/centreon/install/steps/step$step.php", $step, $title, $data);  
  
  if(urlExists("http://localhost/centreon/install/steps/process/process_step$step.php"))
  {
    doUrl("http://localhost/centreon/install/steps/process/process_step$step.php", $step, "$title (process)", $data);
  }
}

echo "<h1>silent configuration</h1>";

echo "\n";
echo "<table>\n";

echo "\n";
echo "<tr>\n";
echo " <th>action</th>\n";
echo " <th>result</th>\n";
echo "</tr>\n";

// steps:
step(1, "Welcome to Centreon Setup");
step(2, "Dependency check up");

$data=array(
  "MONITORING_ENGINE"  => "nagios",
  "INSTALL_DIR_NAGIOS" => "/usr/share/nagios",
  "NAGIOSTATS_BINARY"  => "/usr/bin/nagiostats",
  "NAGIOS_IMG"  => "/usr/share/nagios/html/images",
  "EMBEDDED_PERL"  => ""
);
step(3, "Monitoring engine information", $data);

$data=array(
  "BROKER_MODULE"  => "ndoutils",
  "NDOMOD_BINARY" => "/usr/lib64/nagios/brokers/ndomod.so"
);
step(4, "Broker module information", $data);


$data=array(
  "ADMIN_PASSWORD"  => "admin",  
  "confirm_password"  => "admin",  
  "firstname"  => "admin",  
  "lastname"  => "admin",  
  "email"  => "myemail@myprovider.com"
);
step(5, "Admin information", $data);

$data=array(
  "ADDRESS"  => "localhost",
  "DB_PORT"  => "3306",
  "root_password"  => "root",
  "CONFIGURATION_DB"  => "centreon",
  "STORAGE_DB"  => "centreon_storage",
  "UTILS_DB"  => "centreon_status",
  "DB_USER"  => "centreon",
  "DB_PASS"  => "centreon",
  "db_pass_confirm"  => "centreon"
);
step(6, "Database information", $data);

step(7, "Installation");
doUrl("http://localhost/centreon/install/steps/process/installConfigurationDb.php",7, "Configuration database");
doUrl("http://localhost/centreon/install/steps/process/installStorageDb.php",7, "Storage database");
doUrl("http://localhost/centreon/install/steps/process/installUtilsDb.php",7, "Utils database");
doUrl("http://localhost/centreon/install/steps/process/createDbUser.php",7, "Creating database user");
doUrl("http://localhost/centreon/install/steps/process/insertBaseConf.php",7, "Setting up basic configuration");
doUrl("http://localhost/centreon/install/steps/process/configFileSetup.php",7, "Setting up configuration file");

step(8, "Installation finished");


echo "</table>";
?>
EOF
wget /usr/local/centreon/www/install/silent-install.php -o /tmp/silent-install.php

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip/centreon/"
