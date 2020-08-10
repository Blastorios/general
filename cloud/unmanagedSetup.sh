#!/bin/bash

##Basic Updating of the system and adding your name to the hosst list
echo "Welcome! This script will setup the basics of the server in order to get you started." && sleep 2
echo "First, what's the name of your server? (Capital Sensitive): "
read serversname
sed -i "1 a 127.0.0.1       $serversname" /etc/hosts
while true; do
        read -p "Now for some Git settings, do you want to set the global username and email? (y/n): " yn
        case $yn in
                [Yy]* ) echo "What is your git username?: ";
                        read gitglobalusername;
                        echo "What is your git email?: ";
                        read gitglobalemail;
                        git config --global user.name $gitglobalusername && git config --global user.email $gitglobalemail;
                        echo "$gitglobalusername and $gitglobalemail have been set." && sleep 2; break;;
                [Nn]* ) break;;
                * ) echo "Please answer with yes or No.";;
        esac
done

while true; do
        read -p "Would you like to install Docker-Compose (recommended is 1.26.2)? (y/n): " yn
        case $yn in
                [Yy]* ) echo "What version?: ";
                        read dockercomversion;
                        echo "Docker-Compose version ${dockercomversion:=1.26.2} will be installed!" && sleep 2; 
                        sudo curl -L "https://github.com/docker/compose/releases/download/$dockercomversion/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
                        sudo chmod +x /usr/local/bin/docker-compose; break;;
                [Nn]* ) break;;
                * ) echo "Please answer with yes or No.";;
        esac
done

echo "Now, grab some coffee as I fix some outdated stuff" && sleep 2
echo "We will start with some updates/installations:" && sleep 2
apt-get -y update && apt-get -y upgrade
apt-get install -y python3-dev python3 clamav fail2ban curl wget docker.io unattended-upgrades

##Setting python3 as your default python (for both you and the apps)
while true; do
        read -p "Do you want to set Python3 as your default python? (y/n): " yn
        case $yn in
                [Yy]* ) update-alternatives --remove python /usr/bin/python2;
                        update-alternatives --install /usr/bin/python python /usr/bin/python3 10; 
                        echo "Python3 is now set as default" && sleep 2; break;;
                [Nn]* ) break;;
                * ) echo "Please answer with y or n.";;
        esac
done
##Setting a new port through a prompt which allows you to fill in your own number. Adding the ssh-port to the ufw rules and adding the basic 80, 443 & 9001-9013 while setting the ufw defaults.
echo "Alright, some security is also welcome :)" && sleep 2

##Checking if the user already changed the port to prevent a grep error
if [ $(grep -w "#Port 22" /etc/ssh/sshd_config | wc -l) == 1 ] ; then
        echo "Now choose a new default ssh port (remember to set the same number in Putty if you're using windows)"
        sleep 2
        echo "New port number (e.g. 2001): "
        read sshportnumber
        while true; do
                read -p "Your chosen port number is $sshportnumber, correct? (y/n): " yn
                case $yn in
                        [Yy]* ) sed -i "s/#Port 22/port $sshportnumber/g" /etc/ssh/sshd_config;
                                echo "Changed sshd_config..." && sleep 1; break;;
                        [Nn]* ) echo "Maybe try to do it manually in /etc/ssh/sshd_config"; break;;
                        * ) echo "Please answer with y or n.";;
                esac
        done
else
        echo "You already changed the port.. Very good!"
fi
if [ $(grep -w "PermitRootLogin yes" /etc/ssh/sshd_config | wc -l) == 1 ] ; then
        sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
else
        echo "Already changed rootlogin?... Nice!" && sleep 1
fi
##Changing the ufw rules
ufw default allow outgoing && ufw default deny incoming
ufw allow 80 && ufw allow 443 && ufw allow 8080 && ufw allow 9001:9013/tcp && ufw allow $sshportnumber
echo "Added all the ufw rules..." && sleep 2
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1
sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
sudo /etc/init.d/ssh restart
echo 'y' | ufw enable
echo "SSH and ufw are updated and enabled" && sleep 2

##Adding a user and assigning a password
echo "Now let's add you to the system" && sleep 2
echo "Choose a new username (e.g. 'admin'): "
read inputname
if [ $(grep -w $inputname /etc/group | wc -l) == 0 ] ; then
        adduser $inputname
        usermod -aG sudo $inputname
        usermod -aG docker $inputname
        if [ $(grep -w $inputname /etc/group | wc -l) > 0 ] ; then
                echo "The new user has been made! $inputname is now your new login username and added to the sudo group." && sleep 2
        else
                echo "Hm, something went wrong? Restarting the user creation:" && sleep 2
                echo "Choose a new name (e.g. 'admin'): "
                read inputname
                adduser $inputname
                usermod -aG sudo $inputname
                usermod -aG docker $inputname
                if [ $(grep -w $inputname /etc/group | wc -l) > 0 ] ; then
                        echo "The new user has been made! $inputname is now your new login username and added to the sudo group." && sleep 2
                else
                        echo "Seems to me that the script cannot add a user. Try to do it manually by typing 'adduser $inputname'"
                fi
        fi
else
        echo "You already added this name to the system. I will try to add it to the sudo group..." && sleep 2
        usermod -aG sudo $inputname
        if [ $(grep -w $inputname /etc/sudoers | wc -l) > 0 ] ; then
                echo "Added!" && sleep 2
        else
                echo "I can not seem to add your name..."
                echo "I will end the script now, try 'usermod -aG sudo $inputname' and check if you can your name with 'visudo' in the document."
                echo "Plus, reboot your server after you made your new user"
                exit n
        fi
fi

##Asking for a systemreboot if the user has succesfully made a new systemuser since we disabled root login
reboot_func () {
        while true; do
                read -p "Do you want to restart the system and login as $inputname (y/n)?: " yn
                case $yn in
                        [Yy]* ) echo "Alright... goodluck with the rest of your server" && sleep 2;
                                echo "Do not forget to update your putty and..or ssh login credentials to $inputname and the ssh-port - $sshportnumber" && sleep 2;
                                echo "This was the end of the script, be sure to check Blastorios on GitHub" && sleep 2;
                                echo "Done, Rebooting in 4 seconds..." && sleep 4;
                                reboot;;
                        [Nn]* ) echo "Alright, do not forget to regularly update" && sleep 2;
                                echo "This was the end of the script, be sure to check Blastorios on GitHub" && sleep 2;
                                echo "Done..." && sleep 2; break;;
                        * ) echo "Please answer with y or n.";;
                esac
        done
}
if [ $(grep -w $inputname /etc/group | wc -l) > 0 ] ; then
        reboot_func
else
        echo "Alright, do not forget to regularly update" && sleep 2
        echo "This was the end of the script, be sure to check Blastor1os on GitHub" && sleep 2
        echo "Done..." && sleep 2
        break
fi