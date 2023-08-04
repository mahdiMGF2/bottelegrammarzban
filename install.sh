#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[33mPlease run as root\033[0m"
    exit
fi

wait

echo -e "\e[32mInstalling mirza script ... \033[0m\n"
echo -e "\e[32m mirzapanel by mahdi \033[0m\n"

sudo apt update && apt upgrade -y
echo -e "\e[92mThe server was successfully updated ...\033[0m\n"


PKG=(
    lamp-server^
    libapache2-mod-php 
    mysql-server 
    apache2 
    php-mbstring 
    php-zip 
    php-gd 
    php-json 
    php-curl 
)

for i in "${PKG[@]}"
do
    dpkg -s $i &> /dev/null
    if [ $? -eq 0 ]; then
        echo "$i is already installed"
    else
        apt install $i -y
        if [ $? -ne 0 ]; then
            echo "Error installing $i"
            exit 1
        fi
    fi
done

echo -e "\n\e[92mPackages Installed Continuing ...\033[0m\n"

echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/app-password-confirm password mirzahipass' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/admin-pass password mirzahipass' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/app-pass password mirzahipass' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
sudo apt-get install phpmyadmin -y
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin.conf
sudo systemctl restart apache2
wait
sudo apt-get install -y php-soap
sudo apt-get install libapache2-mod-php
sudo systemctl enable mysql.service
sudo systemctl start mysql.service
sudo systemctl enable apache2
sudo systemctl start apache2
wait
ufw allow 'Apache'
sudo systemctl restart apache2
sudo apt-get install -y git
sudo apt-get install -y wget
sudo apt-get install -y unzip
sudo apt install curl -y
sudo apt-get install -y php-ssh2
sudo apt-get install -y libssh2-1-dev libssh2-1
sudo systemctl restart apache2.service
wait
git clone https://github.com/mahdigholipour3/bottelegrammarzban.git /var/www/html/bottelegrammarzban
sudo chown -R www-data:www-data /var/www/html/bottelegrammarzban/
sudo chmod -R 755 /var/www/html/bottelegrammarzban/
echo -e "\n\033[33mmirza config and script have been installed successfully\033[0m"
wait
if [ ! -d "/root/confmirza" ]; then

    sudo mkdir /root/confmirza

    sleep 1

    touch /root/confmirza/dbrootmirza.txt
    sudo chmod -R 777 /root/confmirza/dbrootmirza.txt
    sleep 1

    randomdbpasstxt=$(openssl rand -base64 10 | tr -dc 'a-zA-Z0-9' | cut -c1-8)

    ASAS="$"

    echo "${ASAS}user = 'root';" >> /root/confmirza/dbrootmirza.txt
    echo "${ASAS}pass = '${randomdbpasstxt}';" >> /root/confmirza/dbrootmirza.txt
    echo "${ASAS}path = '${RANDOM_NUMBER}';" >> /root/confmirza/dbrootmirza.txt

    sleep 1

    passs=$(cat /root/confmirza/dbrootmirza.txt | grep '$pass' | cut -d"'" -f2)
    userrr=$(cat /root/confmirza/dbrootmirza.txt | grep '$user' | cut -d"'" -f2)

    sudo mysql -u $userrr -p$passs -e "alter user '$userrr'@'localhost' identified with mysql_native_password by '$passs';FLUSH PRIVILEGES;"

    echo "SELECT 1" | mysql -u$userrr -p$passs 2>/dev/null

    echo "Folder created successfully!"
else
    echo "Folder already exists."
fi

clear

echo " "
echo -e "\e[32m SSL \033[0m\n"

read -p "Enter the domain: " domainname
if [ "$domainname" = "" ]; then

wait

else
# variables
DOMAIN_NAME="$domainname"
PATHS=$(cat /root/confmirza/dbrootmirza.txt | grep '$path' | cut -d"'" -f2)
(crontab -l ; echo "* 1 * * * curl https://${DOMAIN_NAME}/bottelegrammarzban/Cron_Daily.php >/dev/null 2>&1") | sort - | uniq - | crontab -
(crontab -l ; echo "5 * * * * curl https://${DOMAIN_NAME}/bottelegrammarzban/cron.php >/dev/null 2>&1") | sort - | uniq - | crontab -
sudo ufw allow 80
sudo ufw allow 443
sudo apt install letsencrypt -y
sudo systemctl enable certbot.timer
sudo certbot certonly --standalone --agree-tos --preferred-challenges http -d $DOMAIN_NAME
sudo apt install python3-certbot-apache -y
sudo certbot --apache --agree-tos --preferred-challenges http -d $DOMAIN_NAME

wait

echo " "

ROOT_PASSWORD=$(cat /root/confmirza/dbrootmirza.txt | grep '$pass' | cut -d"'" -f2)
ROOT_USER="root"
echo "SELECT 1" | mysql -u$ROOT_USER -p$ROOT_PASSWORD 2>/dev/null

if [ $? -eq 0 ]; then

wait

    randomdbpass=$(openssl rand -base64 10 | tr -dc 'a-zA-Z0-9' | cut -c1-8)

    randomdbdb=$(openssl rand -base64 10 | tr -dc 'a-zA-Z' | cut -c1-8)

    if [[ $(mysql -u root -p$ROOT_PASSWORD -e "SHOW DATABASES LIKE 'wizwiz'") ]]; then
        clear
        echo -e "\n\e[91mYou have already created the database\033[0m\n"
    else
        dbname=mirzabot
        clear
        echo -e "\n\e[32mPlease enter the database username!\033[0m"
        printf "[+] Default user name is \e[91m${randomdbdb}\e[0m ( let it blank to use this user name ): "
        read dbuser
        if [ "$dbuser" = "" ]; then
        dbuser=$randomdbdb
        fi

        echo -e "\n\e[32mPlease enter the database password!\033[0m"
        printf "[+] Default user name is \e[91m${randomdbpass}\e[0m ( let it blank to use this user name ): "
        read dbpass
        if [ "$dbpass" = "" ]; then
        dbpass=$randomdbpass
        fi

        mysql -u root -p$ROOT_PASSWORD -e "CREATE DATABASE $dbname;" -e "CREATE USER '$dbuser'@'%' IDENTIFIED WITH mysql_native_password BY '$dbpass';GRANT ALL PRIVILEGES ON * . * TO '$dbuser'@'%';FLUSH PRIVILEGES;" -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED WITH mysql_native_password BY '$dbpass';GRANT ALL PRIVILEGES ON * . * TO '$dbuser'@'localhost';FLUSH PRIVILEGES;"

        echo -e "\n\e[95mDatabase Created.\033[0m"

        clear

        printf "\n\e[33m[+] \e[36mBot Token: \033[0m"
        read YOUR_BOT_TOKEN
        printf "\e[33m[+] \e[36mChat id: \033[0m"
        read YOUR_CHAT_ID
        printf "\e[33m[+] \e[36mDomain: \033[0m"
        read YOUR_DOMAIN
        printf "\e[33m[+] \e[36musernamebot: \033[0m"
        read YOUR_BOTNAME
        echo " "
        if [ "$YOUR_BOT_TOKEN" = "" ] || [ "$YOUR_DOMAIN" = "" ] || [ "$YOUR_CHAT_ID" = "" ] || [ "$YOUR_BOTNAME" = "" ]; then
           exit
        fi

        ASAS="$"

        wait

        sleep 1

        file_path="/var/www/html/bottelegrammarzban/config.php"

        if [ -f "$file_path" ]; then
          rm "$file_path"
          echo -e "File deleted successfully."
        else
          echo -e "File not found."
        fi

        sleep 1

        echo -e "<?php" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}APIKEY = '${YOUR_BOT_TOKEN}';" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}usernamedb = '${dbuser}';" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}passworddb = '${dbpass}';" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}dbname = '${dbname}';" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}domainhosts = '${YOUR_DOMAIN}/bottelegrammarzban';" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}adminnumber = '${YOUR_CHAT_ID}';" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}usernamebot = '${YOUR_BOTNAME}';" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "${ASAS}connect = mysqli_connect(localhost, ${ASAS}usernamedb, ${ASAS}passworddb, ${ASAS}dbname);" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "if (${ASAS}connect->connect_error) {" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "die(' The connection to the database failed:' . ${ASAS}connect->connect_error);" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "}" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "mysqli_set_charset(${ASAS}connect, utf8mb4);" >> /var/www/html/bottelegrammarzban/config.php
        echo -e "?>" >> /var/www/html/bottelegrammarzban/config.php

        sleep 1

        curl -F "url=https://${YOUR_DOMAIN}/bottelegrammarzban/index.php" "https://api.telegram.org/bot${YOUR_BOT_TOKEN}/setWebhook"
        MESSAGE="✅ The bot is installed! for start bot send comment /start"
        curl -s -X POST "https://api.telegram.org/bot${YOUR_BOT_TOKEN}/sendMessage" -d chat_id="${YOUR_CHAT_ID}" -d text="$MESSAGE"

        sleep 1

        url="https://${YOUR_DOMAIN}/bottelegrammarzban/install/table.php"
        curl $url

        clear

        echo " "

        echo -e "\e[100mDatabase addres: https://${YOUR_DOMAIN}/phpmyadmin\033[0m"
        echo -e "\e[33mDatabase name: \e[36m${dbname}\033[0m"
        echo -e "\e[33mDatabase username: \e[36m${dbuser}\033[0m"
        echo -e "\e[33mDatabase password: \e[36m${dbpass}\033[0m"
        echo " "

        fi


        elif [ "$ROOT_PASSWORD" = "" ] || [ "$ROOT_USER" = "" ]; then
        echo -e "\n\e[36mThe password is empty.\033[0m\n"
        else 

        echo -e "\n\e[36mThe password is not correct.\033[0m\n"

        fi

fi
