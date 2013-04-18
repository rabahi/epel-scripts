#!/bin/bash

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

echo "disable selinux temporary (without reboot)"
setenforce 0