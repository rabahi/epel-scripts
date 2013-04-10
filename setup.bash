#!/bin/bash

###################################################################
#####################      SERVER CHOICE     ######################
###################################################################

PS3="Please enter your choice: "
options=("Prerequistes" "SCM/srv-scm" "Production/srv-monitoring" "Production/srv-redmine" "Production/srv-intranet" "Build/srv-build-linux" "Build/srv-cit" "Network/srv-mail" "Network/srv-dhcp" "Network/srv-dns" "Network/srv-ldap" "Other/srv-tomcat" "Quit")

select opt in "${options[@]}"
do
    directory=$opt
    case $opt in
        "Prerequistes")
            scripts=("fedora-rpm.bash" "network.bash" "ntp.bash" "selinux.bash" "firewall.bash" "usefullcmd.bash" "httpd.bash" "mysql.bash" "autoupdate.bash" "nagios-nrpe.bash")
            reboot=true
            break
            ;;
        "Build/srv-build-linux")
            scripts=("mock.bash" "rpm.bash" "repos.bash")
            reboot=false
            break
            ;;            
        "Build/srv-cit")
            scripts=("jenkins.bash" "nexus.bash" "sonar.bash")
            reboot=false
            break
            ;;
        "Production/srv-intranet")
            scripts=("wordpress.bash")
            reboot=false
            break
            ;;
        "Production/srv-monitoring")
            scripts=("nagios.bash" "ndoutils.bash" "centreon.bash" "ocsreports.bash" "setup-glpi.bash")
            reboot=false
            break
            ;;
        "Production/srv-redmine")
            scripts=("setup.bash")
            reboot=false
            break
            ;;
        "SCM/srv-scm")
            scripts=("subversion.bash" "git.bash" "hg.bash")
            reboot=false
            break
            ;;
        "Network/srv-mail")
            scripts=("setup-smtp.bash" "setup-imap-pop.bash")
            reboot=false
            break
            ;;
        "Network/srv-dhcp")
            scripts=("setup-dhcp.bash")
            reboot=false
            break
            ;;
        "Network/srv-dns")
            scripts=("setup-dns.bash")
            reboot=false
            break
            ;;
        "Network/srv-ldap")
            scripts=("setup-ldap.bash")
            reboot=false
            break
            ;;
        "Other/srv-tomcat")    
            scripts=("setup-tomcat.bash")
            reboot=false
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

###################################################################
####################      EXECUTE SCRIPTS     #####################
###################################################################

# change directory to $directory
cd $directory

# execute each scripts
for index in "${!scripts[@]}"; do 
  bash "${scripts[$index]}";
done

# now execute installation tests
bash test.bash

# if must reboot, ask for reboot
if $reboot;
then
  PS3="Do you want to reboot now ? (1: yes/2: no) "
  options=("yes" "no")
  select opt in "${options[@]}"
   do
    case $opt in
        "yes")
            reboot
            break
            ;;
        "no")
            echo "you must reboot manually using the following command: reboot"
            break 
            ;;
        *) echo "invalid option $REPLY";;
    esac
  done
fi
