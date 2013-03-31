#!/bin/bash

###################################################################
#####################      SERVER CHOICE     ######################
###################################################################

PS3="Please enter your choice: "
options=("prerequistes" "srv-build-linux" "srv-cit" "srv-intranet" "srv-monitoring" "srv-redmine" "srv-scm" "srv-smtp" "Quit")

select opt in "${options[@]}"
do
    directory=$opt
    case $opt in
        "prerequistes")
            scripts=("network.bash" "ntp.bash" "selinux.bash" "firewall.bash" "usefullcmd.bash" "httpd.bash" "mysql.bash" "autoupdate.bash")
            reboot=true
            break
            ;;
        "srv-build-linux")
            scripts=("mock.bash" "rpm.bash" "repos.bash")
            reboot=false
            break
            ;;            
        "srv-cit")
            scripts=("jenkins.bash" "nexus.bash" "sonar.bash")
            reboot=false
            break
            ;;
        "srv-intranet")
            scripts=("wordpress.bash")
            reboot=false
            break
            ;;
        "srv-monitoring")
            scripts=("nagios.bash" "ndoutils.bash" "centreon.bash" "ocsreports.bash" "setup-glpi.bash")
            reboot=false
            break
            ;;
        "srv-redmine")
            scripts=("setup.bash")
            reboot=false
            break
            ;;
        "srv-scm")
            scripts=("subversion.bash" "git.bash" "hg.bash")
            reboot=false
            break
            ;;
        "srv-smtp")
            scripts=("setup.bash")
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
