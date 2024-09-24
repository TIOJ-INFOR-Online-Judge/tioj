#!/usr/bin/env bash

set -eo pipefail

WORKDIR=${WORKDIR:-~}
DB_USERNAME=${DB_USERNAME:-root}
DB_PASSWORD=${DB_PASSWORD:-SAMPLE_PASSWORD}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ "$EUID" -eq 0 ]]; then
  echo "This script should not be run as root. Instead, run it as a normal user."
  exit 1
fi

if [[ "${SMTP_USERNAME:-}" != "" && "${SMTP_PASSWORD:-}" != "" ]]; then
  echo 'SMTP settings detected. Will enable password recovery.'
else
  echo 'SMTP settings not detected. Will disable password recovery.'
fi
echo 'You can change this later by editing `config/settings.yml` according to `config/settings.yml.example`.'
sleep 1

# Install dependencies using Homebrew
brew update
brew install git cmake ninja mysql imagemagick node yarn redis boost ghc python@3.9

# Start MySQL and Redis services
brew services start mysql
brew services start redis

# Setup MySQL
mysql -u root -e "ALTER USER '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; flush privileges;"

# Install RVM (Ruby Version Manager)
if ! command -v rvm &> /dev/null; then
  curl -sSL https://get.rvm.io | bash -s stable
  source ~/.rvm/scripts/rvm
  rvm install 3.1.2
  rvm use 3.1.2 --default
fi
 ✘ user@userdeMacBook-Pro  ~/Desktop/iscoj-tioj/scripts   main ±  brew install zstd
Warning: zstd 1.5.6 is already installed and up-to-date.
To reinstall 1.5.6, run:
  brew reinstall zstd

# Clone git repos
cd "$WORKDIR"
git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj.git
git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge.git

# Install gems
cd "$WORKDIR/tioj"
passenger_version="$(grep -Po ' passenger \(\K\d.*(?=\))' Gemfile.lock | head -1)"
gem install passenger:"$passenger_version" -N
bundle install

# Install yarn packages
yarn install --frozen-lockfile

# Setup database
cat <<EOF > config/database.yml
default: &default
  adapter: mysql2
  username: $DB_USERNAME
  password: $DB_PASSWORD
  socket: /tmp/mysql.sock
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

# Setup web server (Nginx)
brew install nginx
sudo tee /usr/local/etc/nginx/servers/tioj.conf <<EOF
server {
    listen 80;
    server_name localhost;

    root $WORKDIR/tioj/public;

    passenger_enabled on;
    passenger_ruby $(which ruby);
    passenger_app_env production;
}
EOF

# Start Nginx
brew services start nginx

# Precompile assets and setup database
rails assets:precompile
rails db:setup

# Setup judge client
cd "$WORKDIR/tioj-judge"
mkdir -p build
cd build
cmake -G Ninja ..
ninja -j $(($(sysctl -n hw.ncpu)-2))
sudo ninja install

# Setup judge config
cat <<EOF > /usr/local/etc/tioj-judge.conf
tioj_url = http://localhost
tioj_key = $(head -c 32 /dev/urandom | xxd -ps -c 128)
parallel = 2
max_submission_queue_size = 20
EOF

# Start services
brew services restart nginx
brew services restart redis
brew services restart mysql
