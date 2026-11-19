# Direct Installation Migration to TIOJ 3.6

Since RVM is now unmaintained, TIOJ is migrating to [mise](https://mise.jdx.dev/) on version 3.6 as its canonical environment manager for both the web server and the judge client. If you are using a direct installation setup, follow the steps below to migrate your TIOJ installation.

## 1. Stop the TIOJ services

```bash
sudo systemctl stop nginx
sudo systemctl stop tioj-judge
```

## 2. Remove RVM and old packages

The removal of Yarn, Node.js, GHC, and Rust is optional, but it is highly recommended to remove them to avoid conflicts with mise.

```bash
sudo apt autoremove rvm yarn nodejs ghc rustc
```

After this, remove `source "/etc/profile.d/rvm.sh"` and any other RVM-related lines from your `~/.bashrc`.

## 3. Install new dependencies

First, install `software-properties-common` for adding PPAs:

```bash
sudo apt -y install software-properties-common
```

Then, install mise and other dependencies. The commands differ based on your Ubuntu version. For Ubuntu 22.04 and 24.04, use the following commands:

```bash
sudo apt -y install extrepo
sudo extrepo enable mise
sudo apt-add-repository -y ppa:ubuntu-toolchain-r/test
sudo apt install g++-15 mise libbz2-dev libreadline-dev libgmp-dev libsqlite3-dev libbsd-dev
sudo rm -f /etc/alternatives/cpp
sudo update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-15 60 \
    --slave /usr/bin/c++ c++ /usr/bin/g++-15
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 60 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-15 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-15 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-15 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-15
```

For Ubuntu 26.04, run:

```bash
sudo add-apt-repository -y ppa:jdxcode/mise
sudo apt install mise libbz2-dev libreadline-dev libgmp-dev libsqlite3-dev libbsd-dev libjitterentropy3-dev
```

## 4. Setup Mise

This installs Ruby and other dependencies for TIOJ. Adding `mise` to your shell startup script is optional but highly recommended to allow easy future runs like `bundle install` or `yarn install`.

```bash
eval $(mise activate bash)
mise plugin add ghc
MISE_FETCH_REMOTE_VERSIONS_TIMEOUT=300 mise install python@2.7 python@3.14 rust@1.93 ghc@9.10
mise use -g node@26 yarn@4 ruby@4.0 gem:rubocop@1.92
mise exec python@3.14 -- pip3 install numpy~=2.5.0 Pillow~=13.0.0
chmod 711 $HOME
# optional but highly recommended
echo 'eval $(mise activate bash)' >> ~/.bashrc
```

## 5. Update the judge client

Starting from [tioj-judge](https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge) 2.5.0, a system user is required to run the judge client:

```bash
sudo useradd -r tioj-judge -s /usr/sbin/nologin -d /var/lib/tioj-judge
printf 'uid = %s\ngid = %s\n' $(id -u tioj-judge) $(id -g tioj-judge) | sudo tee -a /etc/tioj-judge.conf
```

After that, pull the latest version (2.5.0 or above) of the judge client and rebuild it:

```bash
cd [your tioj-judge setup directory]
git pull # update to newest

rm -rf build
cmake -B build -G Ninja -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build
sudo cmake --install build
```

Finally, configure the `tioj-judge.service` to use the mise environment. First, run the following command:

```bash
python3 -c 'import os; h=os.environ["HOME"]; m=f"{h}/.local/share/mise"; i=f"{m}/installs"; print(f"""Environment="PATH={i}/rust/1.93:{i}/python/3.14/bin:{i}/python/2.7/bin:{i}/ghc/9.10/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"\nEnvironment="TIOJ_JUDGE_MOUNTS={m}:{h}/.cargo:{h}/.rustup"\nEnvironment="CARGO_HOME={h}/.cargo"\nEnvironment="RUSTUP_HOME={h}/.rustup\"""")'
```

Then, paste the result of the above command into the `[Service]` section of `/etc/systemd/system/tioj-judge.service`, replacing the old `Environment` lines.

## 6. Update the web server

```bash
cd [your TIOJ setup directory]
git pull # pull the latest version

bundle install
yarn install --frozen-lockfile
RAILS_ENV=production rails assets:precompile
sudo env "PATH=$PATH" "HOME=$HOME" passenger-install-nginx-module --force-colors --auto --auto-download --languages ruby
```

Note that as of 2026-11-18, the bundled Nginx version is 1.30.6, which is affected by vulnerabilities like [CVE-2026-123007](https://nvd.nist.gov/vuln/detail/cve-2026-123007). To fix this, you can manually download and install Nginx 1.30.7 with the following commands, replacing the `passenger-install-nginx-module` command above:

```bash
wget https://nginx.org/download/nginx-1.30.7.tar.gz
tar -xf nginx-1.30.7.tar.gz
sudo env "PATH=$PATH" "HOME=$HOME" passenger-install-nginx-module --force-colors --auto --nginx-source-dir=./nginx-1.30.7 --languages ruby
sudo rm -rf nginx-1.30.7 nginx-1.30.7.tar.gz
```

After the last command, you will see a message like this:

```
passenger_root /home/tioj/.local/share/mise/installs/ruby/[version]/lib/ruby/gems/[version]/gems/passenger-[version];
passenger_ruby /home/tioj/.local/share/mise/installs/ruby/[version]/bin/ruby;
```
Use these to replace the similar two lines in `/opt/nginx/conf/nginx.conf`.

## 7. Update auto session trim script trigger

The old installation script might fail to trigger the auto session trim script. To fix this, run the following command:

```bash
TIOJ_SETUP_DIR=[your TIOJ setup directory]
printf '30 3 * * * %s "%s/scripts/trim_sessions.sh"\n' "$USER" "$TIOJ_SETUP_DIR" | sudo tee /etc/cron.d/tioj-trim-sessions > /dev/null
```

This runs auto session trimming at 3:30 AM every day. You can change the time by modifying the first part of the command.

After that, check if `/etc/crontab` or `crontab -e` contains any similar session trim command. If it does, remove them to avoid duplicate triggers.

## 8. Restart the services

```bash
sudo systemctl daemon-reload
sudo systemctl restart nginx
sudo systemctl restart tioj-judge
```
