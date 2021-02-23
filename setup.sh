#!/bin/bash

set -x

TIOJ_PATH=$HOME/tioj
MIKU_PATH=$HOME/miku
DB_USERNAME=root
DB_PASSWORD=SAMPLE_PASSWORD
URL=http://localhost

ubuntu_distribution=`cat /etc/lsb-release | grep "RELEASE" | awk -F= '{ print $2 }'`

if [[ $ubuntu_distribution == "16.04" ]]; then
	sudo add-apt-repository ppa:ubuntu-toolchain-r/test
	sudo add-apt-repository ppa:carsten-uppenbrink-net/openssl
fi

sudo apt-add-repository -y ppa:rael-gc/rvm 
wget https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb -O /tmp/mac.deb

if [[ $ubuntu_distribution == "20.04" ]]; then
	echo "Choose ubuntu bionic for alternative in next interactive window."
fi
echo "Please choose mysql 5.7 in next interactive window."
read -n 1 -p "Press any key to continue."
sudo dpkg -i /tmp/mac.deb # Prepare to install MySQL

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install gcc-9 g++-9 python python3 ghc rvm imagemagick mysql-server libmysqlclient-dev libcurl4-openssl-dev openssl -y
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 \
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

git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj $TIOJ_PATH
git clone https://github.com/TIOJ-INFOR-Online-Judge/miku $MIKU_PATH
git submodule update --init -C $MIKU_PATH

cd $TIOJ_PATH
bundle install

echo "Please choose ruby as main programming language and use default settings in next interactive window."
read -n 1 -p "Press any key to continue."
sudo rvmsudo passenger-install-nginx-module

sudo sed -i '/http {/a \ \ \ \ passenger_app_env production;' /opt/nginx/conf/nginx.conf
sudo sed -i "/^[^#]*server_name/a \ \ \ \ \ \ \ \ passenger_enabled on;\n\ \ \ \ \ \ \ \ root $TIOJ_PATH/public;" /opt/nginx/conf/nginx.conf

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

cd $TIOJ_PATH
cat <<EOF > config/initializers/secret_token.rb
Tioj::Application.config.secret_token = "$TOKEN"
EOF

cat <<EOF > config/initializers/fetch_key.rb
Tioj::Application.config.fetch_key = "$KEY"
EOF

cd $MIKU_PATH
cat <<EOF > app/tioj_url.py
tioj_url = "$URL"
tioj_key = "$KEY"
EOF

cd $TIOJ_PATH
RAILS_ENV=production rake db:create db:schema:load db:seed
RAILS_ENV=production rake assets:precompile
mkdir public/announcement
echo -n '{"name":"","message":""}' > public/announcement/anno

cd $MIKU_PATH
make -j

