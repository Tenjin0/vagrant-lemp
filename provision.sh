#!/bin/bash

echo "Provisioning virtual machine..."

#  update
#echo "Update Ubuntu"
#sudo apt-get update
#sudo apt-get install curl
# Git
echo "Installing package"
sudo apt-get install -y nano

# Node
echo "\n--- Installing Node ---\n"
sudo curl -sL https://deb.nodesource.com/setup_0.10 | sudo bash -
sudo apt-get update
sudo apt-get install -y nodejs
sudo npm install -g -y grunt grunt-cli bower

echo "\n--- Installing nvm ---\n"
#curl https://raw.githubusercontent.com/creationix/nvm/v0.25.4/install.sh | bash
#source ~/.profile
#nvm install v0.10.38
#echo nvm use 0.10.38
# Nginx
echo "\n--- Installing Nginx ---\n"
sudo apt-get install -y nginx

echo -e "\n--- Installing PHP ---\n"
sudo apt-get install -y php5-cli php5-fpm php5-common php5-dev

echo -e "\n--- Installing PHP extensions ---\n"
sudo apt-get install -y php5-mysql php5-curl php5-gd php-pear #php5-mcrypt
# php5-imagick php5-imapphp5-intl php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# MySQL
echo -e "\n--- Preparing MySQL ---\n"
APPENV=local
DBHOST=localhost
DBNAME=si
DBUSER="read"
DBPASSWD=yoda
DBPASSWD2=chewie

echo -e "\n--- Installing MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get -y install mysql-server-5.6 phpmyadmin

echo -e "\n--- Setting up MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD2'"
#mysql -uroot -p$DBPASSWD -e "create user '$DBUSER'@'%' identified by ''$DBPASSWD2'"

echo -e "\n--- Installing Composer ---\n"
curl -sS https://getcomposer.org/installer | php
php -r "readfile('https://getcomposer.org/installer');" | php
sudo mv composer.phar /usr/local/bin/composer
php /var/www/netmessage-extranet/composer.phar update

# Nginx Configuration
echo -e "\n--- Configuring Nginx ---\n"
#sudo cp /var/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost
sudo ln -s config/nginx_vhost /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/

sudo rm -rf /etc/nginx/sites-available/default

# Restart Nginx for the config to take effect
sudo service nginx restart

sudo apt-get -y autoremove
echo -e "\n--- Finished provisioning ---\n"
