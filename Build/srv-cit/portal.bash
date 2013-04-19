#!/bin/bash

cat > /var/www/html/portal.inc.php << "EOF"
<h2>Continious Integration</h2>
<ul>
  <li><a href="/jenkins/">Jenkins</a></li>
  <li><a href="/nexus/">Nexus</a></li>
  <li><a href="/sonar/">Sonar</a></li>
</ul>
EOF