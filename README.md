[TIOJ INFOR Online Judge](http://tioj.ck.tp.edu.tw/)
==

### Remember to change secret token in production!!!

## Current Development Environment
Ruby: 2.6.5
Rails: 4.2.11

## Installation guide

It is recommended to deploy TIOJ on Ubuntu 16.04 LTS or 18.04 LTS. The following guide uses RVM for Ruby, Passenger + Nginx for web server.

#### 1. Install prerequisites

You need to follow the instructions on the screen when installing / setting up those packages.

```
# add-apt-repository ppa:ubuntu-toolchain-r/test        # If Ubuntu 16.04 LTS is used
# add-apt-repository ppa:carsten-uppenbrink-net/openssl # If Ubuntu 16.04 LTS is used
# apt-add-repository -y ppa:rael-gc/rvm # PPA for RVM
$ wget https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb
# dpkg -i mysql-apt-config_0.8.11-1_all.deb # Prepare to install MySQL
# apt update
# apt install g++-9 python python3 ghc rvm imagemagick mysql-server \
  libmysqlclient-dev libcurl4-openssl-dev openssl
# update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 \
  --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
  --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-9 \
  --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-9 \
  --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-9 # Use GCC 9 as default
# mysql_secure_installation # Setup MySQL
# usermod -a -G rvm $USER
$ echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc
$ echo 'PATH=$HOME/.rvm/gems/ruby-2.6.5/bin:$PATH' >> ~/.bashrc
$ source ~/.bashrc
$ rvm install 2.6.5
$ rvm use --default 2.6.5
$ gem install rails -v 4.2.11
```

#### 2. Clone TIOJ and its judge program

```
$ git clone https://github.com/adrien1018/tioj
$ git clone https://github.com/adrien1018/miku
$ cd miku
$ git submodule update --init
```

#### 3. Install gems

```
$ bundle install
```

#### 4. Install web server

```
$ rvmsudo passenger-install-nginx-module
```

When prompted for selecting the language, select Ruby. Use all recommended settings.

#### 5. Configure Nginx

```
# vim /opt/nginx/conf/nginx.conf
```
You need to add some settings to the Nginx configuration:
```
http {
  # ... some settings ...
  passenger_app_env production;

  # The Passenger version and the username may be different from this example.
  # You need to use the path given in the previous step.
  passenger_root /home/tioj/.rvm/gems/ruby-2.6.5/gems/passenger-6.0.4;
  passenger_ruby /home/tioj/.rvm/gems/ruby-2.6.5/wrappers/ruby;

  server {
    # ... some settings ...
    passenger_enabled on;
    root ${TIOJ_PATH}/public; # Replace ${TIOJ_PATH} with the path to the cloned 'tioj' repository
  }
}
```

#### 6. Edit database settings

Add the following to `tioj/config/database.yml` and change `${PASSWORD}` to the password of the MySQL root account:

```
development:
 adapter: mysql2
 database: tioj_dev
 host: localhost
 username: root
 password: ${PASSWORD}
 encoding: utf8
test:
 adapter: mysql2
 database: tioj_test
 host: localhost
 username: root
 password: ${PASSWORD}
 encoding: utf8
production:
 adapter: mysql2
 database: tioj_production
 host: localhost
 username: root
 password: ${PASSWORD}
 encoding: utf8
 socket: /var/run/mysqld/mysqld.sock # You may need to check MySQL settings to get the socket path
```

#### 7. Generate keys

There are two keys need to be generated. The first is the Rails secret token, and the second is the key to update judge results. The following shell script can do this:

```
URL= # The URL of webpage (e.g. 'http://127.0.0.1' or 'https://some.website.com'), without the terminating '/'
TIOJ_PATH= # The path to the cloned 'tioj' repository
JUDGE_PATH= # The path to the cloned 'miku' repository

cd $TIOJ_PATH
TOKEN=$(rake secret)
KEY=$(rake secret)
cat <<EOF >config/initializers/secret_token.rb
Tioj::Application.config.secret_token = "$TOKEN"
EOF
cat <<EOF >config/initializers/fetch_key.rb
Tioj::Application.config.fetch_key = "$KEY"
EOF
cd $JUDGE_PATH
cat <<EOF >app/tioj_url.py
tioj_url = "$URL"
tioj_key = "$KEY"
EOF
```

#### 8. Create database & assets & announcements

```
# Inside `tioj` repository
RAILS_ENV=production rake db:create db:schema:load db:seed
RAILS_ENV=production rake assets:precompile
mkdir public/announcement
echo -n '{"name":"","message":""}' > public/announcement/anno
```

#### 9. Compile judge server

```
# Inside `miku` repository
make # -j8 for parallel compilation
```

### Done!

Now start the web server and the judge server:
```
# /opt/nginx/sbin/nginx
# ${JUDGE_PATH}/bin/miku --parallel 2 -b 100 --verbose --aggressive-update
```

You can add the commands to systemd for the convenience of starting / stopping those servers.
