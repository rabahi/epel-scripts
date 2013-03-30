#!/bin/bash

# load check_functions.
. ../check_functions/check_functions.bash

# check pages
check_web_function nagios http://localhost/nagios/
check_web_function centreon http://localhost/centreon/
check_web_function ocsreports http://localhost/ocsreports/
check_web_function glpi http://localhost/glpi/

# check services:
check_service httpd
check_service mysqld

check_service ndo2db
check_service nagios

# check tcp port:
check_tcp 80 #httpd
check_tcp 3306 #mysqld
