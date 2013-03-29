#!/bin/bash

###################################################################
#####################      SERVER CHOICE     ######################
###################################################################

PS3="Please enter your choice: "
options=("prerequistes" "srv-1" "srv-2" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "prerequistes")
            echo "you chose choice 1"
            directory=$opt
            scripts=("script1.sh" "script2.sh")
            reboot=true
            break
            ;;
        "Option 2")
            echo "you chose choice 2"
            ;;
        "Option 3")
            echo "you chose choice 3"
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
bash test.sh

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
