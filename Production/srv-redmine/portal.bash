#!/bin/bash

cat > /var/www/html/portal.inc.php << "EOF"
<h2>Redmine</h2>
<ul>
  <li><a href="/redmine">Redmine (login:admin; password: admin)</a></li>
</ul>
EOF