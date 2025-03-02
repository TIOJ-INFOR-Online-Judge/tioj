#!/usr/bin/env bash

set -eo pipefail

WORKDIR=${WORKDIR:-~}
DB_USERNAME=${DB_USERNAME:-root}
DB_PASSWORD=${DB_PASSWORD:-SAMPLE_PASSWORD}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ "$EUID" -eq 0 ]]; then
  echo "This script should not be run as root. Instead, run it as a normal user with sudo privilege."
  exit 1
fi

if [[ "${SMTP_USERNAME:-}" != "" && "${SMTP_PASSWORD:-}" != "" ]]; then
  echo 'SMTP settings detected. Will enable password recovery.'
else
  echo 'SMTP settings not detected. Will disable password recovery.'
fi
echo 'You can change this later by editing `config/settings.yml` according to `config/settings.yml.example`.'
sleep 1

{ # prevent sudo timeout
  while true; do
    sudo -v
    sleep 30
  done
} &
SUDO_PID=$!

# Cleanup job
function Cleanup {
  kill $SUDO_PID 2> /dev/null
  if [[ -n "${PASSENGER_LOG:+1}" ]]; then
    sudo rm -rf $PASSENGER_LOG
  fi
  if [[ -n "${TAIL_PID:+1}" ]]; then
    sudo rm -rf $TAIL_PID
  fi
}
trap Cleanup EXIT

# Install dependencies
if grep -q 'Ubuntu' /etc/*-release; then
  DIST=Ubuntu
  UBUNTU_DIST=`cat /etc/lsb-release | grep "RELEASE" | awk -F= '{ print $2 }'`
  sudo apt -y update
  sudo apt -y install software-properties-common
  sudo apt-add-repository -y ppa:rael-gc/rvm
  sudo mkdir -p /etc/apt/keyrings
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  if [ "$UBUNTU_DIST" != "22.04" ]; then
    sudo apt-add-repository -y ppa:ubuntu-toolchain-r/test
  fi
  sudo apt -y update
  sudo DEBIAN_FRONTEND=noninteractive apt -y install \
      git cmake ninja-build g++-11 rvm \
      mysql-server mysql-client libmysqlclient-dev libcurl4-openssl-dev \
      imagemagick nodejs yarn redis-server \
      libseccomp-dev libnl-3-dev libnl-genl-3-dev libboost-all-dev libzstd-dev \
      ghc python2 python3-numpy python3-pil
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
  DIST=Arch
  sudo pacman -Syu --noconfirm --needed \
      base-devel git mariadb imagemagick nodejs yarn redis libyaml \
      cmake ninja boost ghc python-numpy python-pillow
  sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
  sudo systemctl enable mysql
  sudo systemctl start mysql
  curl -L get.rvm.io | sudo bash -

  # build libseccomp, libnl, openssl, sqlite, libbsd, libzstd with static libs
  mkdir -p "$WORKDIR/build"
  cd "$WORKDIR/build"
  mkdir -p libseccomp libnl openssl sqlite libbsd zstd
  cd libseccomp
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/libseccomp/-/raw/main/PKGBUILD
  sed -i "s/^makedepends.*$/\0\noptions=('staticlibs' !'lto')/" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../libnl
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/libnl/-/raw/main/PKGBUILD
  sed -i "s/^depends.*$/\0\noptions=('staticlibs' !'lto')/" PKGBUILD
  sed -Ei '/sbindir/, /disable-static/ s/(--d| \\).*//' PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../openssl
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/openssl/-/raw/main/PKGBUILD
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/openssl/-/raw/main/ca-dir.patch
  sed -i "s/^makedepends.*$/\0\noptions=('staticlibs' !'lto')/" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../sqlite
  for i in PKGBUILD license.txt sqlite-lemon-system-template.patch; do
    curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/sqlite/-/raw/main/$i
  done
  sed -i "s/^options=./\0'staticlibs' !'lto' /; /disable-static/ d" PKGBUILD
  makepkg -si --noconfirm
  cd ../libbsd
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/libbsd/-/raw/main/PKGBUILD
  sed -i "/rm.*libbsd\.a/ d" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../zstd
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/zstd/-/raw/main/PKGBUILD
  sed -i "s/makedepends.*$/\0\noptions=('staticlibs' !'lto')/; /-DZSTD_BUILD_STATIC=OFF/ d" PKGBUILD
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
newgrp rvm <<< 'rvm install 3.3.7; rvm alias create default 3.3.7'
rvm use 3.3.7

# Clone git repos
cd "$WORKDIR"
git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj.git
git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge.git

# Solve MariaDB incompatibility in Arch
if [[ "$DIST" == 'Arch' ]]; then
  sed -i 's/utf8mb4_0900_ai_ci/uca1400_nopad_ai_ci/g' tioj/db/schema.rb
fi

# Install gems
cd "$WORKDIR/tioj"
passenger_version="$(grep -Po ' passenger \(\K\d.*(?=\))' Gemfile.lock | head -1)"
gem install passenger:"$passenger_version" -N
PASSENGER_LOG=$(sudo mktemp -d)
sudo chmod 755 $PASSENGER_LOG
export rvmsudo_secure_path=1
rvmsudo -b bash -c "passenger-install-nginx-module --force-colors --auto --auto-download --languages ruby > $PASSENGER_LOG/log 2>&1; touch $PASSENGER_LOG/finished 2> /dev/null"
MAKEFLAGS='-j4' bundle install

# Install yarn packages
yarn install --frozen-lockfile

# Setup database
cat <<EOF > config/database.yml
default: &default
  adapter: mysql2
  username: $DB_USERNAME
  password: $DB_PASSWORD
  socket: /var/run/mysqld/mysqld.sock
  encoding: utf8mb4
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

if [[ "${SMTP_USERNAME:-}" != "" && "${SMTP_PASSWORD:-}" != "" ]]; then
  cat <<EOF > config/settings.yml
shared:
  mail_settings:
    smtp_settings:
      address: ${SMTP_ADDRESS:-smtp.gmail.com}
      port: ${SMTP_PORT:-587}
      user_name: $SMTP_USERNAME
      password: $SMTP_PASSWORD
      enable_starttls_auto: true
    url_options:
      host: ${MAIL_HOSTNAME:-hostname}
    sender: ${MAIL_SENDER:-$SMTP_USERNAME}
EOF
fi

EDITOR=true rails credentials:edit
rails assets:precompile
TIOJ_KEY=$FETCH_KEY rails db:setup

# Setup judge client
cd "$WORKDIR/tioj-judge"
mkdir -p build
cd build
cmake -G Ninja ..
ninja -j $(($(nproc)-2))
sudo ninja install

sudo tee /etc/tioj-judge.conf <<EOF > /dev/null
tioj_url = http://localhost
tioj_key = $FETCH_KEY
parallel = 2
max_submission_queue_size = 20
EOF

# Setup nginx
cd "$WORKDIR/tioj"
tail -f -n +1 $PASSENGER_LOG/log &
TAIL_PID=$!
until stat $PASSENGER_LOG/finished > /dev/null 2>&1; do
  sleep 1
done
kill $TAIL_PID
unset TAIL_PID
sudo sed -i "s/^.*nobody.*$/user $USER;/" /opt/nginx/conf/nginx.conf
sudo sed -i 's/http {/\0\n    passenger_app_env production;/' /opt/nginx/conf/nginx.conf
sudo sed -i "s|^[^#]*server_name.*localhost.*$|\0\n        passenger_enabled on;\n        root $(pwd)/public;\n        client_max_body_size 1024M;\n        location /cable {\n            passenger_app_group_name cable;\n            passenger_force_max_concurrent_requests_per_process 0;\n            passenger_env_var PASSENGER_CABLE 1;\n        }\n|" /opt/nginx/conf/nginx.conf
sudo sed -Ei "/^ *location \/[^a-z]/, /\}/ s|^ {8}|\0# |" /opt/nginx/conf/nginx.conf

# Setup systemctl
cat <<EOF | sudo tee /etc/systemd/system/nginx.service > /dev/null
[Unit]
Description=Nginx Server
After=syslog.target
Requires=network.target remote-fs.target nss-lookup.target mysql.service

[Service]
Type=forking
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
sudo echo '30 3 * * * /tioj/scripts/trim_sessions.sh' >> /etc/crontab
