#!/usr/bin/env bash

set -eo pipefail

WORKDIR=${WORKDIR:-~}
DB_USERNAME=${DB_USERNAME:-root}
DB_PASSWORD=${DB_PASSWORD:-SAMPLE_PASSWORD}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

{ # prevent sudo timeout
  while true; do
    sudo -v
    sleep 30
  done
} &

# Install dependencies
if grep -q 'Ubuntu' /etc/*-release; then
  UBUNTU_DIST=`cat /etc/lsb-release | grep "RELEASE" | awk -F= '{ print $2 }'`
  sudo apt -y update
  sudo apt -y install software-properties-common
  sudo apt-add-repository -y ppa:rael-gc/rvm
  if [ "$UBUNTU_DIST" != "22.04" ]; then
    sudo apt-add-repository -y ppa:ubuntu-toolchain-r/test
  fi
  sudo DEBIAN_FRONTEND=noninteractive apt -y install \
      git cmake ninja-build g++-11 rvm \
      mysql-server mysql-client libmysqlclient-dev libcurl4-openssl-dev \
      imagemagick nodejs redis-server \
      libseccomp-dev libnl-3-dev libnl-genl-3-dev libboost-all-dev ghc
  if [ "$UBUNTU_DIST" != "22.04" ]; then
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-11 \
      --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-11 \
      --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-11 \
      --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-11 # Use GCC 11 as default
  fi

  # Setup mysql
  sudo mysql <<< "ALTER USER '$DB_USERNAME'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD'; flush privileges;"

  REDIS_SERVICE=redis-server
elif grep -q 'Arch Linux' /etc/*-release; then
  sudo pacman -Syu --noconfirm --needed base-devel git cmake ninja mariadb nodejs redis boost
  sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
  sudo systemctl enable mysql
  sudo systemctl start mysql
  curl -L get.rvm.io | sudo bash -

  # build libseccomp, libnl, openssl, sqlite, libbsd with static libs
  cd "$WORKDIR"
  mkdir libseccomp libnl openssl sqlite libbsd
  cd libseccomp
  curl -O https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/libseccomp/trunk/PKGBUILD
  sed -i "s/makedepends.*$/\0\noptions=('staticlibs')/" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../libnl
  curl -O https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/libnl/trunk/PKGBUILD
  sed -i "s/^options.*$/options=('staticlibs')/" PKGBUILD
  sed -Ei '/sbindir/, /disable-static/ s/(--d| \\).*//' PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../openssl
  curl -O https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/openssl/trunk/PKGBUILD
  curl -O https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/openssl/trunk/ca-dir.patch
  sed -i "s/makedepends.*$/\0\noptions=('staticlibs')/" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../sqlite
  for i in PKGBUILD license.txt sqlite-lemon-system-template.patch; do
    curl -O https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/sqlite/trunk/$i
  done
  sed -i "s/options=./\0'staticlibs' /; /disable-static/ d" PKGBUILD
  makepkg -si --noconfirm
  cd ../libbsd
  curl -O https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/libbsd/trunk/PKGBUILD
  sed -i "/rm.*libbsd\.a/ d" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm

  # Setup mysql
  sudo mysql <<< "ALTER USER '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; flush privileges;"
  REDIS_SERVICE=redis
else
  echo 'Unknown distribution'
  exit 1
fi

# Setup RVM
sudo usermod -a -G rvm $USER
echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc
source "/etc/profile.d/rvm.sh"
newgrp rvm <<< 'rvm install 3.1.2; rvm alias create default 3.1.2'
rvm use 3.1.2

# Clone git repos
cd "$WORKDIR"
git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj.git
git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge.git

# Install gems
cd "$WORKDIR/tioj"
git checkout new-judge # remove this after merge
MAKEFLAGS='-j4' bundle install

# Setup nginx
rvmsudo_secure_path=1 rvmsudo passenger-install-nginx-module --auto --auto-download --languages ruby
sudo sed -i "s/^.*nobody.*$/user $USER;/" /opt/nginx/conf/nginx.conf
sudo sed -i 's/http {/\0\n    passenger_app_env production;/' /opt/nginx/conf/nginx.conf
sudo sed -i "s|^[^#]*server_name.*localhost.*$|\0\n        passenger_enabled on;\n        root $(pwd)/public;|" /opt/nginx/conf/nginx.conf
sudo sed -Ei "/^ *location \//, /\}/ s|^ {8}|\0# |" /opt/nginx/conf/nginx.conf

# Setup database
cat <<EOF > config/database.yml
default: &default
  adapter: mysql2
  username: $DB_USERNAME
  password: $DB_PASSWORD
  socket: /var/run/mysqld/mysqld.sock
  encoding: utf8
development:
  <<: *default
  database: tioj_dev
test:
  <<: *default
  database: tioj_test
production:
  <<: *default
  database: tioj_production
EOF

# Setup web server
FETCH_KEY=$(head -c 32 /dev/urandom | xxd -ps -c 128)
export RAILS_ENV=production
EDITOR=cat rails credentials:edit
rails assets:precompile
TIOJ_KEY=$FETCH_KEY rails db:setup

# Setup judge client
cd "$WORKDIR/tioj-judge"
mkdir -p build
cd build
cmake -G Ninja ..
ninja
sudo ninja install

sudo tee /etc/tioj-judge.conf <<EOF > /dev/null
tioj_url = http://localhost
tioj_key = $FETCH_KEY
parallel = 2
max_submission_queue_size = 200
EOF

# Setup systemctl
cat <<EOF | sudo tee /etc/systemd/system/nginx.service > /dev/null
[Unit]
Description=Nginx Server
After=syslog.target
Requires=network.target remote-fs.target nss-lookup.target mysql.service

[Service]
Type=forking
Environment="LOGLEVEL=debug"
PIDFile=/opt/nginx/logs/nginx.pid
ExecStartPre=/opt/nginx/sbin/nginx -t
ExecStart=/opt/nginx/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=false

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | sudo tee /etc/systemd/system/tioj-judge.service > /dev/null
[Unit]
Description=TIOJ Judge Client
After=syslog.target network.target

[Service]
Type=simple
StandardOut=syslog
StandardError=syslog
SyslogIdentifier=tioj-judge
ExecStart=/usr/bin/nice -n -10 tioj-judge -v
ExecStop=/bin/kill -s INT \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable "$REDIS_SERVICE"
sudo systemctl enable nginx
sudo systemctl enable tioj-judge
sudo systemctl start "$REDIS_SERVICE"
sudo systemctl start nginx
sudo systemctl start tioj-judge

kill %1
