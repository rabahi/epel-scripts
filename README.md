centos-scripts
==============

Prerequistes:
-------------

Centos 6.4 or higher.

Usage:
------

# install git
yum -y install git

# get scripts
git clone https://github.com/cousiano/centos-scripts /opt/centos-scripts

# execute:
cd /opt/centos-scripts
bash setup.bash

How does it work?
----------------

Each installation kind has it own directory.
In each directory we must have:
- some bash scripts
- test.bash : this script will check if installation is well passed.

**Note**: directory name must have the same name as the installation kind. 
