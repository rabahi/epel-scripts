#!/bin/bash
 
echo "install rpmdevtools automake autoconf gcc"
yum -y install rpmdevtools rpmlint automake autoconf gcc make

echo "clean rpmbuild directory"
rm ~/rpmbuild/ -fr

##################################################
#      EXAMPLE FILE : HELLO WORLD 
##################################################
echo "create build files"
mkdir -p ~/rpmbuild/BUILD/
cat >~/rpmbuild/BUILD/Makefile.am << "EOF"
bin_PROGRAMS=hello
hello_SOURCES=hello.c
EOF

cat >~/rpmbuild/BUILD/configure.ac << "EOF"
AC_INIT([hello], [1.0], [bug@libhello.org])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_PROG_CC
AC_PROG_RANLIB
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
EOF

cat >~/rpmbuild/BUILD/hello.c << "EOF"
#include <stdio.h>
int main(int argc, char* argv[])
{
printf("Hello, world!\n");
return 0;
}
EOF

# move to ~/rpmbuild/BUILD
echo "move to ~/rpmbuild/BUILD"
cd ~/rpmbuild/BUILD

# create macros for automake
aclocal

# create Makefile.in from Makefile.am
automake --add-missing --copy

# create configure
autoconf

##################################################
#      SPEC FILE 
##################################################
echo "create SPECS file"
mkdir -p ~/rpmbuild/SPECS/
cd ~/rpmbuild/SPECS/
rpmdev-newspec hello

echo "configure spec file"
sed -i "s/^Version:/Version:        1.0/g" hello.spec
sed -i "s/^Summary:/Summary:        My newpackage rocks\!/g" hello.spec
sed -i "s/^Group:/Group:          Development\/Tools/g" hello.spec
sed -i "s/^License:/License:        GPL/g" hello.spec
sed -i "s/^URL:/URL:            http:\/\/mysite\/hello.html/g" hello.spec
sed -i "s/^Source0:/Source0:        ./g" hello.spec
sed -i "s/^\(BuildRequires:\)/#\1/g" hello.spec
sed -i "s/^\(Requires:\)/#\1/g" hello.spec
sed -i "s/^\(\%prep\)/#\1/g" hello.spec
sed -i "s/^\(\%doc\)/\1\\n\/usr\/bin\/hello/g" hello.spec
sed -i "s/^\(\%changelog\)/\1\\n* Tue May 02 2014 marc rabahi <marc.rabahi@gmail.com> 1.0-1\n- my hello world change log./g" hello.spec

##################################################
#      BUILD RPM 
##################################################

echo "Check patches and BR":
rpmbuild -bp hello.spec

echo "Build":
rpmbuild -bc --short-circuit hello.spec

echo "Package %files":
rpmbuild -bi --short-circuit hello.spec

echo "Finally build rpm":
rpmbuild -ba hello.spec

##################################################
#      CHECK RPM 
##################################################
echo "Now check commons errors in RPM packages (rpm software, sources rpm)"
rpmlint ~/rpmbuild/RPMS/x86_64/hello-1.0-1.el7.centos.x86_64.rpm
rpmlint ~/rpmbuild/SRPMS/hello-1.0-1.el7.centos.src.rpm

