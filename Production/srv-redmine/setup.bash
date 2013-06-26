#!/bin/bash

##################################################
#      PARAMETERS 
##################################################

redmine_install_url=http://rubyforge.org/frs/download.php/76933/redmine-2.3.1.tar.gz
redmine_version=redmine-2.3.1

##################################################
#      INSTALLATION SCRIPT
##################################################
echo "create database redmine, user/password redmine/redmine":
mysql --user=root --password=root -e "CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'redmine';"
mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS redmine;"
mysql --user=root --password=root -e "use redmine; GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost' WITH GRANT OPTION;"

echo "1 - install rvm (Ruby Version Manager)"
yum -y install curl
curl -L get.rvm.io | bash -s stable

source ~/.bash_profile
rvm get stable --auto
rvm requirements

echo "2- install ruby"
rvm install 1.9.3
rvm use 1.9.3 --default

echo "3- install rubygem"
rvm rubygems current

echo "install bundle and nokogiri"
gem install bundle
gem install nokogiri

echo "install passenger"
yum -y install curl-devel httpd-devel
gem install passenger
passenger-install-apache2-module -a

echo "configure httpd (create /etc/httpd/conf.d/redmine.conf)"
cat > /etc/httpd/conf.d/redmine.conf << "EOF"
LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p429/gems/passenger-4.0.5/libout/apache2/mod_passenger.so
PassengerRoot               /usr/local/rvm/gems/ruby-1.9.3-p429/gems/passenger-4.0.5
PassengerRuby               /usr/local/rvm/bin/ruby
 
<VirtualHost *:80>
   ServerName redmine.mycompany.com
   DocumentRoot /opt/redmine/redmine/public
   <Directory /opt/redmine/redmine/public>
      # This relaxes Apache security settings.
      AllowOverride all
      # MultiViews must be turned off.
      Options -MultiViews
      allow from all
   </Directory>

   ErrorLog "|/usr/sbin/rotatelogs /etc/httpd/logs/redmine-error.%Y-%m-%d.log 86400"
   CustomLog "|/usr/sbin/rotatelogs /etc/httpd/logs/redmine-access.%Y-%m-%d.log 86400" "%h %l %u %t %D \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""

</VirtualHost>
EOF


echo "get redmine"
mkdir -p /opt/redmine/download
cd /opt/redmine/download
wget $redmine_install_url  # GET LATEST VERSION ON RUBYFORGE
tar xvfz $redmine_version.tar.gz
mv $redmine_version ../redmine

echo "configure database"
cd /opt/redmine/redmine/config
cp database.yml.example database.yml
sed -i "s/username: root/username: redmine/g" /opt/redmine/redmine/config/database.yml
sed -i "s/password: \"\"/password: redmine/g" /opt/redmine/redmine/config/database.yml

echo "install redmine"
yum -y install mysql-devel ImageMagick-devel freetds-devel
cd /opt/redmine/redmine
bundle install

echo "now populate database"
cd /opt/redmine/redmine
rake generate_secret_token
rake db:migrate RAILS_ENV="production"
rake redmine:load_default_data RAILS_ENV="production"

echo "set chmod on tmp directory"
chmod 777 /opt/redmine/redmine/tmp/ -R

echo "start httpd service"
service httpd restart


##################################################
#      CONFIGURATION SUB-URI
##################################################
# NOTE REDMINE MUST BE STARTED "NORMALLY" BEFORE THIS STEP.

cat > /etc/httpd/conf.d/redmine.conf << "EOF"
LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p429/gems/passenger-4.0.5/libout/apache2/mod_passenger.so
PassengerRoot               /usr/local/rvm/gems/ruby-1.9.3-p429/gems/passenger-4.0.5
PassengerRuby               /usr/local/rvm/bin/ruby

   
<VirtualHost *>
  ServerName YOUR_SERVER
  DocumentRoot /var/www/html
  RailsEnv production
  RailsBaseURI /redmine
  PassengerDefaultUser apache

   ErrorLog "|/usr/sbin/rotatelogs /etc/httpd/logs/redmine-error.%Y-%m-%d.log 86400"
   CustomLog "|/usr/sbin/rotatelogs /etc/httpd/logs/redmine-access.%Y-%m-%d.log 86400" "%h %l %u %t %D \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""

</VirtualHost>
EOF
ln -s /opt/redmine/redmine/public /var/www/html/redmine

echo "sleep 5s (wait httpd to start and configure redmine)"
sleep 5

echo "restart httpd service"
service httpd restart

myip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "Now meet you here: http://$myip"
