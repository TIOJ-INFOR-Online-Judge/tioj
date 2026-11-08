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
export MAKEFLAGS="-j$(nproc)"
if grep -q 'Ubuntu' /etc/*-release; then
  DIST=Ubuntu
  UBUNTU_DIST=`cat /etc/lsb-release | grep "RELEASE" | awk -F= '{ print $2 }'`
  sudo apt -y update
  sudo apt -y install software-properties-common
  sudo mkdir -p /etc/apt/keyrings
  if [ "$UBUNTU_DIST" == "26.04" ]; then
    sudo add-apt-repository -y ppa:jdxcode/mise
  else
    sudo apt install -y extrepo
    sudo extrepo enable mise
    sudo apt-add-repository -y ppa:ubuntu-toolchain-r/test
  fi
  sudo apt -y update
  sudo DEBIAN_FRONTEND=noninteractive apt -y install \
      git g++-15 cmake ninja-build curl mise imagemagick redis-server \
      mysql-server mysql-client libmysqlclient-dev libcurl4-openssl-dev \
      libseccomp-dev libnl-genl-3-dev libsqlite3-dev libbsd-dev libgmp-dev \
      libz-dev libbz2-dev libreadline-dev libssl-dev libboost-all-dev libzstd-dev
  if [ "$UBUNTU_DIST" == "26.04" ]; then
    sudo apt install -y g++ libjitterentropy3-dev
  else
    if [ "$UBUNTU_DIST" == "24.04" ]; then
      sudo rm /etc/alternatives/cpp
    fi
    sudo update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-15 60 \
      --slave /usr/bin/c++ c++ /usr/bin/g++-15
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 60 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-15 \
      --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-15 \
      --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-15 \
      --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-15 # Use GCC 15 as default
  fi

  # Setup mysql
  sudo mysql <<< "ALTER USER '$DB_USERNAME'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_PASSWORD'; flush privileges;"

  REDIS_SERVICE=redis-server
elif grep -q 'Arch Linux' /etc/*-release; then
  DIST=Arch
  sudo pacman -Syu --noconfirm --needed \
      base-devel git mariadb imagemagick redis mise libyaml cmake ninja boost zlib-static cronie \
      libseccomp libnl openssl sqlite libbsd zstd # first install it to get version
  sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
  sudo systemctl enable mysql
  sudo systemctl start mysql

  # build libseccomp, libnl, openssl, sqlite, libbsd, libzstd with static libs
  mkdir -p "$WORKDIR/build"
  cd "$WORKDIR/build"
  mkdir -p libseccomp libnl openssl sqlite libbsd zstd
  cd libseccomp
  VER="$(pacman -Q libseccomp | cut -d' ' -f2)"
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/libseccomp/-/raw/$VER/PKGBUILD
  sed -i "s/^pkgrel.*$/\0\noptions=('staticlibs' !'lto')/" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../libnl
  VER="$(pacman -Q libnl | cut -d' ' -f2)"
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/libnl/-/raw/$VER/PKGBUILD
  sed -i "s/^pkgrel.*$/\0\noptions=('staticlibs' !'lto')/" PKGBUILD
  sed -Ei '/sbindir/, /disable-static/ s/(--d| \\).*//' PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../openssl
  VER="$(pacman -Q openssl | cut -d' ' -f2)"
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/openssl/-/raw/$VER/PKGBUILD
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/openssl/-/raw/$VER/ca-dir.patch
  sed -i "s/^pkgrel.*$/\0\noptions=('staticlibs' !'lto')/; "'s|make DESTDIR|make PATH="/usr/bin/core_perl:$PATH" DESTDIR|' PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../sqlite
  VER="$(pacman -Q sqlite | cut -d' ' -f2)"
  for i in PKGBUILD license.txt sqlite-lemon-system-template.patch; do
    curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/sqlite/-/raw/$VER/$i
  done
  sed -i "s/^options=./\0'staticlibs' !'lto' /; /disable-static/ d" PKGBUILD
  makepkg -si --noconfirm
  cd ../libbsd
  VER="$(pacman -Q libbsd | cut -d' ' -f2)"
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/libbsd/-/raw/$VER/PKGBUILD
  sed -i "/rm.*libbsd\.a/ d" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm
  cd ../zstd
  VER="$(pacman -Q zstd | cut -d' ' -f2)"
  curl -O https://gitlab.archlinux.org/archlinux/packaging/packages/zstd/-/raw/$VER/PKGBUILD
  sed -i "s/pkgrel.*$/\0\noptions=('staticlibs' !'lto')/; /-DZSTD_BUILD_STATIC=OFF/ d" PKGBUILD
  sed -i "s|patch -Np1.*$|\0\nsed -i 's/contentChecksum_t/LZ4F_contentChecksum_t/g' programs/fileio.c|" PKGBUILD
  makepkg -si --skippgpcheck --nocheck --noconfirm

  # Setup mysql
  sudo mysql <<< "ALTER USER '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; flush privileges;"
  REDIS_SERVICE=redis
else
  echo 'Unknown distribution'
  exit 1
fi

# Setup mise
mise plugin add ghc
# ghc install sometimes fail
mise install ghc@9.10 || mise install ghc@9.10
mise use -g ghc@9.10 python@2.7 python@3.14 rust@1.93 node@22 npm:yarn@1.22 ruby@4.0 gem:rubocop@1.92
eval $(mise activate bash)
pip3 install numpy~=2.5.0 Pillow~=13.0.0

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
PASSENGER_LOG=$(sudo TMPDIR=/var/tmp mktemp -d)
sudo chmod 755 $PASSENGER_LOG
sudo setsid env "PATH=$PATH" "HOME=$HOME" bash -c "passenger-install-nginx-module --force-colors --auto --auto-download --languages ruby > $PASSENGER_LOG/log 2>&1; touch $PASSENGER_LOG/finished 2> /dev/null"
bundle install --retry 3

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
cmake -B build -G Ninja -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build -j $(nproc)
sudo cmake --install build

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
After=syslog.target network.target remote-fs.target nss-lookup.target mysql.service
Wants=network.target remote-fs.target nss-lookup.target mysql.service

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
StandardOutput=journal
StandardError=journal
SyslogIdentifier=tioj-judge
ExecStart=/usr/bin/nice -n -10 tioj-judge -v
ExecStop=/bin/kill -s INT \$MAINPID
Environment="PATH=$HOME/.local/share/mise/installs/rust/1.93:$HOME/.local/share/mise/installs/python/3.14/bin:$HOME/.local/share/mise/installs/python/2.7/bin:$HOME/.local/share/mise/installs/ghc/9.10/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="TIOJ_JUDGE_MOUNTS=$HOME/.local/share/mise:$HOME/.cargo:$HOME/.rustup"
Environment="CARGO_HOME=$HOME/.cargo"
Environment="RUSTUP_HOME=$HOME/.rustup"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable "$REDIS_SERVICE"
sudo systemctl enable nginx
sudo systemctl enable tioj-judge
sudo systemctl start "$REDIS_SERVICE"
sudo systemctl start nginx
sudo systemctl start tioj-judge
printf '30 3 * * * %s "%s/tioj/scripts/trim_sessions.sh"\n' "$USER" "$WORKDIR" | sudo tee /etc/cron.d/tioj-trim-sessions > /dev/null
