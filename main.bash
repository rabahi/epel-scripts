#!/bin/bash

###################################################################
######################      GLOBAL VARS     #######################
###################################################################

g_server=""
g_skipPrerequistes=false

###################################################################
####################      CHECK ARGUMENTS     #####################
###################################################################

display_usage() {
  echo -e "************************** USAGE ********************"
  echo 
  echo -e "$0 [OPTIONS]"
  echo
  echo -e "OPTIONS are:"
  echo -e "\t-s|--server [server-name]\t\tinstall the server name"
  echo -e "\t-p|--skip-prerequistes [true|false]\tdo not execute prerequistes scripts (default : $g_skipPrerequistes)"
  echo
  echo
  echo -e "SERVER-NAME are:"
  echo -e "\t-Build/srv-build-linux"
  echo -e "\t-Build/srv-cit"
  echo -e "\t-Database/srv-database"
  echo -e "\t-Network/srv-dhcp"
  echo -e "\t-Network/srv-dns"
  echo -e "\t-Network/srv-ldap"
  echo -e "\t-Network/srv-mail"
  echo -e "\t-Network/srv-vpn"
  echo -e "\t-Other/srv-ftp"
  echo -e "\t-Other/srv-nfs"
  echo -e "\t-Other/srv-samba"
  echo -e "\t-Other/srv-snmp"
  echo -e "\t-Other/srv-syslog"
  echo -e "\t-Other/srv-tomcat"
  echo -e "\t-Production/srv-intranet"
  echo -e "\t-Production/srv-monitoring"
  echo -e "\t-Production/srv-redmine"
  echo -e "\t-SCM/srv-scm"
  echo
  echo
  echo -e "EXAMPLE :"
  echo -e "$0 -s Build/srv-build-linux"
  exit 0
}

if [[ ($# == 0) || ( $1 == "--help") ||  $1 == "-h" ]] 
then
  display_usage  
fi

while [[ $# > 1 ]]
do
  key="$1"

  shift

  case $key in
      -s|--server)
      g_server="$1"
      shift
      ;;
      -p|--skip-prerequistes)
      g_skipPrerequistes="$1"
      shift
      ;;
      *) # unknown option
       display_usage
      ;;
  esac
done


prerequistes_scripts=("external-repos.bash" "firewall.bash" "network.bash" "ntp.bash" "selinux.bash" "usefullcmd.bash" "httpd.bash" "../Database/srv-database/mariadb.bash" "autoupdate.bash" "nagios-nrpe.bash" "webmin.bash" "portal.bash")
case $g_server in
  "Build/srv-build-linux")
      scripts=("mock.bash" "rpm.bash" "repos.bash")
      shift
      ;;            
  "Build/srv-cit")
      scripts=("jenkins.bash" "nexus.bash" "sonar.bash")
      shift
      ;;
  "Database/srv-database")
      scripts=("mariadb.bash" "postgres.bash")
      shift
      ;;
  "Production/srv-intranet")
      scripts=("wordpress.bash" "mediawiki.bash")
      shift
      ;;
  "Production/srv-monitoring")
      scripts=("nagios.bash" "ndoutils.bash" "centreon.bash" "ntop.bash" "setup-glpi.bash")
      shift
      ;;
  "Production/srv-redmine")
      scripts=("setup.bash")
      shift
      ;;
  "SCM/srv-scm")
      scripts=("subversion.bash" "git.bash" "hg.bash")
      shift
      ;;
  "Network/srv-mail")
      scripts=("setup-smtp.bash" "setup-imap-pop.bash")
      shift
      ;;
  "Network/srv-dhcp")
      scripts=("setup-dhcp.bash")
      shift
      ;;
  "Network/srv-dns")
      scripts=("setup-dns.bash")
      shift
      ;;
  "Network/srv-ldap")
      scripts=("setup-ldap.bash")
      shift
      ;;
  "Network/srv-vpn")
      scripts=("setup-vpn.bash")
      shift
      ;;
  "Other/srv-tomcat")
      scripts=("setup-tomcat.bash")
      shift
      ;;
  "Other/srv-ftp")
      scripts=("setup-ftp.bash")
      shift
      ;;
  "Other/srv-samba")
      scripts=("setup-samba.bash")
      shift
      ;;
  "Other/srv-snmp")
      scripts=("setup.bash")
      shift
      ;;
  "Other/srv-syslog")
      scripts=("setup.bash")
      shift
      ;;
  "Other/srv-nfs")    
      scripts=("setup-nfs.bash")
      shift
      ;;
  "Prerequistes")    
      scripts=("${prerequistes_scripts[@]}")
      g_skipPrerequistes=true;
      shift
      ;;
  *)
     echo "invalid server $g_server";
     display_usage
esac

echo "server = $g_server"
echo "skipPrerequistes = $g_skipPrerequistes"

###################################################################
####################      EXECUTE SCRIPTS     #####################
###################################################################

if ! $g_skipPrerequistes;
then
  # execute each prerequistes scripts
  for index in "${!prerequistes_scripts[@]}"; do
    bash "Prerequistes/${prerequistes_scripts[$index]}";
  done
fi

# execute each scripts
for index in "${!scripts[@]}"; do 
  bash "$g_server/${scripts[$index]}";
done

# update portal
if [ -f "$g_server/portal.bash" ]
then
    bash "$g_server/portal.bash"
fi

# now execute installation tests
bash "$g_server/test.bash";

if ! $g_skipPrerequistes;
then  
  bash "Prerequistes/test.bash";
fi
