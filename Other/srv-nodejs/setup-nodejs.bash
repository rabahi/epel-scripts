#!/bin/bash

echo "install prerequistes"
dnf -y install nodejs

echo "create working directory"
mkdir -p /var/www/nodejs

echo "create nodejs server"
cat > /var/www/nodejs/server.js << "EOF"
var http = require('http');


var server = http.createServer(function(req, res) {

  res.writeHead(200);

  res.end('Hello World !!');

});

server.listen(4587);

EOF


echo "create service"
cat > /etc/systemd/system/myNodeJsService.service << "EOF"
[Unit]
Description=my node.js service
 
[Install]
WantedBy=multi-user.target
 
[Service]
ExecStart=/usr/bin/node /var/www/nodejs/server.js
Restart=on-success
StandardOutput=syslog
StandardError=syslog
WorkingDirectory=/var/www/nodejs
Type=simple
User=root
Group=root
KillMode=process
PrivateTmp=true

EOF


systemctl enable myNodeJsService.service
systemctl start myNodeJsService.service
