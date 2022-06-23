[TIOJ INFOR Online Judge](http://tioj.ck.tp.edu.tw/)
==

### Remember to change secret token in production!!!

## Current Development Environment
Ruby: 2.7.6
Rails: 5.2.8

## Installation guide

It is recommended to deploy TIOJ on Ubuntu 20.04 LTS or 22.04 LTS. The following guide uses RVM for Ruby, Passenger + Nginx for web server.

#### 1. Install prerequisites

You need to follow the instructions on the screen when installing / setting up those packages.

```
# apt-add-repository -y ppa:rael-gc/rvm # PPA for RVM
# dpkg -i mysql-apt-config_0.8.11-1_all.deb # Prepare to install MySQL
# apt update
# apt install python python3 ghc rvm imagemagick mysql-server \
  libmysqlclient-dev libcurl4-openssl-dev openssl nodejs
# mysql_secure_installation # Setup MySQL
# usermod -a -G rvm $USER
$ # ruby needs openssl 1.1.1 while default is openssl 3, so compile it manually
$ wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/openssl/1.1.1l-1ubuntu1.3/openssl_1.1.1l.orig.tar.gz
$ tar -xf openssl_1.1.1l.orig.tar.gz
$ cd openssl-1.1.1l/
$ ./config shared enable-ec_nistp_64_gcc_128 -Wl,-rpath=/usr/local/ssl/lib --prefix=/usr/local/ssl
$ make -j4
# make install
$ echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc
$ echo 'PATH=$HOME/.rvm/gems/ruby-2.7.6/bin:$PATH' >> ~/.bashrc
$ source ~/.bashrc
$ rvm install 2.7.6 --with-openssl-dir=/usr/local/ssl/
$ rvm use --default 2.7.6
```

#### 2. Clone TIOJ and its judge program

```
$ git clone https://github.com/TIOJ-INFOR-Online-Judge/tioj
$ git clone https://github.com/TIOJ-INFOR-Online-Judge/miku
$ cd miku
$ git submodule update --init
```

#### 3. Install gems

```
$ bundle install  # in tioj/
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
  passenger_root /home/tioj/.rvm/gems/ruby-2.7.6/gems/passenger-6.0.14;
  passenger_ruby /home/tioj/.rvm/gems/ruby-2.7.6/wrappers/ruby;

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

### 10. Switch to cgroups v1

Add `GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"` to `/etc/default/grub`, run `sudo update-grub` and then reboot.

### Done!

Now start the web server and the judge server:
```
# /opt/nginx/sbin/nginx
# PATH=${JUDGE_PATH}/app:${JUDGE_PATH}/bin:$PATH \
  ${JUDGE_PATH}/bin/miku --parallel 2 -b 100 --verbose --aggressive-update
```

You can add the commands to systemd for the convenience of starting / stopping those servers.


## Judge Management

TIOJ has an admin control panel located at `/admin` (powered by [Active Admin](https://activeadmin.info/)), which has an independent authentication system. The default admin username and password are both `admin` (set in `db/seeds.rb` and created when running `rake db:seed`).

Though one can add/edit some settings through the control panel, it is not the recommended way to manage the judge (and it might lead to some errors). Instead, one should create an ordinary account, enter the `Users` tab in the control panel to set the account as an admin account, and use it to do all ordinary management such as problem setting, testdata uploading, and article creation.
