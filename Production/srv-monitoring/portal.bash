#!/bin/bash

cat > /var/www/html/portal.inc.php << "EOF"
<h2>Monitoring</h2>
<ul>
  <li><a href="/nagios/">Nagios (login: nagiosadmin; password: nagiosadmin)</a></li>
  <li><a href="/centreon/">Centreon (login: nagiosadmin; password: nagiosadmin)</a></li>
  <li><a href="/ocsreports/">OCS (login: admin; password: admin)</a></li>
  <li><a href="/glpi/">GLPI (login: glpi; password: glpi)</a></li>
  <li><a href="/ntopng/">NTOP-NG (login: admin; password: admin)</a></li>
</ul>
EOF