#!/bin/bash

cat > /var/www/html/index.php << "EOF"
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title>Administration portal</title>
</head>
 
<body>
 
<center><h1>Administration portal</h1></center>
 
<h2>Prerequistes</h2>
<ul>
  <li><a href="webmin/">Webmin</a> (use login: root; password: root)</li>
  <li><a href="phpMyAdmin/">phpMyAdmin</a> (use login: root; password: root)</li>
</ul>

<?php 
 if(file_exists("portal.inc.php"))
 {
   include("portal.inc.php");
 }
?>

</body>
</html>
EOF