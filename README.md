centos-scripts
==============

What's this??
-------------
These scripts are 'getting started' scripts.


Prerequistes:
-------------

Centos 6.5 x64 or higher.

Usage:
------

- install git
`yum -y install git`

- get scripts
`git clone https://github.com/cousiano/centos-scripts /opt/centos-scripts`

- execute:
```bash
  cd /opt/centos-scripts
  bash setup.bash
```

Recommandations
----------------

- First, install prerequistes and reboot your server
- Then, install your server (i.e. srv-***)
- Finally, update the security policy (depends on your own case)

Enjoy :)

How does it work?
----------------

Each installation kind has it own directory.
In each directory we must have:
- some bash scripts
- test.bash : this script will check if installation is well passed.

**Note**: directory name must have the same name as the installation kind. 
