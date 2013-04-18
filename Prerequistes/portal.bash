#!/bin/bash

cat > /var/www/html/index.html << "EOF"
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title>Administration portal</title>
</head>
 
<body>
 
<center><h1>Administration portal</h1></center>
 
<h2>Source Code Management</h2>
<ul>
  <li><a href="webmin/">Webmin</a></li>
  <li><a href="phpMyAdmin/">phpMyAdmin</a></li>
</ul>
 
</body>
</html>
EOF