#!/bin/bash

cat > /var/www/html/portal.inc.php << "EOF"
<h2>SCM</h2>
<ul>
  <li><a href="/svn/">Subversion</a></li>
  <li><a href="/git/">Git</a></li>
  <li><a href="/hg/">Mercurial</a></li>
</ul>
EOF