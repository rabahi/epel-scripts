centos-scripts
==============

What's this??
-------------
These scripts are 'getting started' scripts.


Prerequistes:
-------------

epel-7 or higher.

Usage:
------

- install git
`yum -y install git`

- get scripts
`git clone https://github.com/cousiano/centos-scripts /opt/centos-scripts`

- execute:
```bash
  cd /opt/centos-scripts
  bash main.bash --help
```

Recommandations
----------------

- First, ask for the script help:
```bash
  echo "display the help"
  bash main.bash --help
```

- Then, install your server (i.e. srv-***)
```bash  
  echo "install my server"
  bash main.bash -s SERVER-NAME
```

- Finally, update the security policy (depends on your own case)

Enjoy :)

Script Options
----------------
 * skip-prerequistes : 
```bash
   bash main.bash -s SERVER-NAME --skip-prerequistes true
```

How does it work?
----------------

Each installation kind has it own directory.
In each directory we must have:
- some bash scripts
- test.bash : this script will check if installation is well passed.

**Note**: directory name must have the same name as the installation kind. 
