#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
DATABASE_NAME='vagrant_boilderplate'
PASSWORD='database_password1'
XDEBUG_INI_PATH='/etc/php/7.3/mods-available/xdebug.ini'
export DEBIAN_FRONTEND=noninteractive

sudo ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf
sudo dpkg-reconfigure debconf -f noninteractive -p critical

# update / upgrade
echo "Updating repos..."
sudo apt-get update
#sudo apt-get -y upgrade

# install latest apache and php 7.3
echo "Installing apache2..."
sudo apt-get install -y apache2 1> /dev/null
echo "Installing PHP 7.3..."
sudo apt-get install -y php7.3 1> /dev/null
echo "Installing PHP modules..."
sudo apt-get install -y php-mbstring 1> /dev/null
sudo apt-get install -y php-json 1> /dev/null
sudo apt-get install -y php-soap 1> /dev/null
sudo apt-get install -y php-dom 1> /dev/null
sudo apt-get install -y php-curl 1> /dev/null
sudo apt-get install -y php-zip 1> /dev/null
sudo apt-get -y install php-mysql 1> /dev/null
sudo apt-get -y install php-redis 1> /dev/null
sudo apt-get install -y php-gd 1> /dev/null
sudo apt-get install -y php-imagick 1> /dev/null

echo "Installing Xdebug 2.7..."
sudo apt-get install -y php-xdebug 1> /dev/null
sudo echo "xdebug.remote_enable=true" >> $XDEBUG_INI_PATH
sudo echo "xdebug.remote_connect_back=true" >> $XDEBUG_INI_PATH
sudo echo 'xdebug.remote_host="192.168.33.10"' >> $XDEBUG_INI_PATH
sudo echo "xdebug.idekey=PHPSTORM" >> $XDEBUG_INI_PATH
sudo echo "xdebug.remote_port=9000" >> $XDEBUG_INI_PATH
sudo echo "xdebug.remote_autostart=on" >> $XDEBUG_INI_PATH
sudo echo "xdebug.max_nesting_level=1000" >> $XDEBUG_INI_PATH
sudo service apache2 restart

# install mysql and give password to installer
echo "Installing MySQL Server..."
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD" 1> /dev/null
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD" 1> /dev/null
sudo apt-get -y install default-mysql-server 1> /dev/null
sudo replace "127.0.0.0" "0.0.0.0" -- /etc/mysql/mariadb.conf.d/50-server.cnf
sudo mysql -u root -p${PASSWORD} -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$PASSWORD');"
sudo mysql -u root -p${PASSWORD} -e "UPDATE mysql.user SET Host='%' WHERE Host='localhost' AND User='root';"
sudo mysql -u root -p${PASSWORD} -e "FLUSH PRIVILEGES"
sudo service mysql restart
sudo mysql -u root -p${PASSWORD} -e "create database ${DATABASE_NAME}"
sudo mysql -u root -p${PASSWORD} -e "create database ${DATABASE_NAME}"

echo "Installing Redis Server..."
sudo apt-get -y install redis 1> /dev/null

echo "Installing SQLite"
sudo apt-get -y install sqlite3 1> /dev/null
sudo apt-get -y install php7.3-sqlite 1> /dev/null
sudo service apache2 restart

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
#sudo apt-get -y install phpmyadmin

echo "Setting up apache..."
# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/"
    <Directory "/var/www/html/">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite 1> /dev/null

# restart apache
service apache2 restart 1> /dev/null

# install git
echo "Installing git..."
sudo apt-get -y install git 1> /dev/null

# install curl
echo "Installing curl..."
sudo apt-get -y install curl 1> /dev/null

# install vim
echo "Installing vim..."
sudo apt-get -y install vim 1> /dev/null

# install Composer
echo "Installing composer..."
curl -s https://getcomposer.org/installer | php 1> /dev/null
mv composer.phar /usr/local/bin/composer

echo "Configuring .bashrc..."
echo 'PROJECT_PATH="/var/www/html"' >> ~/.bashrc
echo 'alias l="ls -alt"' >> ~/.bashrc
echo 'alias gtp="cd $PROJECT_PATH"' >> ~/.bashrc
sh ~/.bashrc

echo "Provisioning done!"
