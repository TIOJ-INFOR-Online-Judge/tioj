#!/bin/bash

TIOJ_PATH=$HOME/tioj
MIKU_PATH=$HOME/miku
DB_USERNAME=root
DB_PASSWORD=SAMPLE_PASSWORD
URL=http://localhost

ubuntu_distribution=`cat /etc/lsb-release | grep "RELEASE" | awk -F= '{ print $2 }'`

set -x

if [[ $ubuntu_distribution == "16.04" ]]; then
	sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
	sudo add-apt-repository ppa:carsten-uppenbrink-net/openssl -y
fi

wget https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb -O /tmp/mac.deb

if [[ $ubuntu_distribution == "20.04" ]]; then
	echo "Choose ubuntu bionic for alternative in next interactive window."
fi
echo "Please choose mysql 5.7 in next interactive window."
read -n 1 -p "Press any key to continue."
sudo dpkg -i /tmp/mac.deb # Prepare to install MySQL

sudo add-apt-repository ppa:rael-gc/rvm -y 
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
sudo apt update --allow-unauthenticated
sudo apt install gcc-9 g++-9 python python3 ghc rvm imagemagick mysql-server libmysqlclient-dev libcurl4-openssl-dev openssl libcap-dev -y
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-9 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-9 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-9 # Use GCC 9 as default

# sudo mysql_secure_installation # Setup MySQL
if [[ $ubuntu_distribution == "18.04" ]]; then
    sudo mysql <<< "ALTER USER '$DB_USERNAME'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD'; flush privileges;"
fi
sudo usermod -a -G rvm $USER

echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc
echo "PATH=$HOME/.rvm/gems/ruby-2.6.5/bin:$PATH" >> ~/.bashrc

newgrp rvm << RVMGRPEOF

set -x

source /etc/profile.d/rvm.sh
PATH=$HOME/.rvm/gems/ruby-2.6.5/bin:$PATH

rvm install 2.6.5
rvm alias create default 2.6.5

RVMGRPEOF

source /etc/profile.d/rvm.sh
PATH=$HOME/.rvm/gems/ruby-2.6.5/bin:$PATH

gem install rails -v 4.2.11

git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj $TIOJ_PATH
git clone https://github.com/TIOJ-INFOR-Online-Judge/miku $MIKU_PATH
cd $MIKU_PATH
git submodule update --init

cd $TIOJ_PATH
bundle install

echo "Please choose ruby as main programming language and use default settings in next interactive window."
read -n 1 -p "Press any key to continue."
 
rvmsudo_secure_path=1 /usr/share/rvm/bin/rvmsudo /usr/share/rvm/gems/ruby-2.6.5/bin/passenger-install-nginx-module

sudo sed -i '/http {/a \ \ \ \ passenger_app_env production;' /opt/nginx/conf/nginx.conf
sudo sed -i "/^[^#]*server_name/a \ \ \ \ \ \ \ \ passenger_enabled on;\n\ \ \ \ \ \ \ \ root $TIOJ_PATH/public;" /opt/nginx/conf/nginx.conf
sudo sed -i "/^\ *location \/ {/, /}/ s|^\(\ \{8\}\)|\1# |" /opt/nginx/conf/nginx.conf

cat <<EOF > config/database.yml
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: $DB_USERNAME
  password: $DB_PASSWORD
  socket: /var/run/mysqld/mysqld.sock

development:
  <<: *default
  database: tioj_development

test:
  <<: *default
  database: tioj_test

production:
  <<: *default
  database: tioj_production
EOF

TOKEN=$(rake secret)
KEY=$(rake secret)

cat <<EOF > $TIOJ_PATH/config/initializers/secret_token.rb
Tioj::Application.config.secret_token = "$TOKEN"
EOF

cat <<EOF > $TIOJ_PATH/config/initializers/fetch_key.rb
Tioj::Application.config.fetch_key = "$KEY"
EOF

cat <<EOF > $MIKU_PATH/app/tioj_url.py
tioj_url = "$URL"
tioj_key = "$KEY"
EOF

cd $TIOJ_PATH
RAILS_ENV=production rake db:create db:schema:load db:seed
RAILS_ENV=production rake assets:precompile
mkdir public/announcement
echo -n '{"name":"","message":""}' > public/announcement/anno

sudo make -j -C $MIKU_PATH

