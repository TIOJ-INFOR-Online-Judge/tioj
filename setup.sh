#!/bin/bash

ubuntu_distribution=`cat /etc/lsb-release | grep "RELEASE" | awk -F= '{ print $2 }'`

if [[ $ubuntu_distribution == "16.04" ]] then
	sudo add-apt-repository ppa:ubuntu-toolchain-r/test
	sudo add-apt-repository ppa:carsten-uppenbrink-net/openssl
fi

sudo apt-add-repository -y ppa:rael-gc/rvm 
wget https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb -O /tmp/mac.deb

if [[ $ubuntu_distribution == "20.04" ]] then
	echo "Choose ubuntu bionic for alternative in following interactive window."
fi
echo "Please choose mysql 5.7 in following interactive window."
read -n 1 -p "Press any key to continue."
sudo dpkg -i /tmp/mac.deb # Prepare to install MySQL

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install gcc-9 g++-9 python python3 ghc rvm imagemagick mysql-server libmysqlclient-dev libcurl4-openssl-dev openssl
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 
    --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-9 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-9 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-9 # Use GCC 9 as default

sudo mysql_secure_installation # Setup MySQL
sudo usermod -a -G rvm $USER

old_group=`id -g`
newgrp rvm

echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc
echo 'PATH=$HOME/.rvm/gems/ruby-2.6.5/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

rvm install 2.6.5
rvm use --default 2.6.5
gem install rails -v 4.2.11

newgrp $old_group
