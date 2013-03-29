#!/bin/bash

echo "Append rule to open port 80"
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
echo "Save rule"
service iptables save
echo "Now activate new rule."
service iptables restart
