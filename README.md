[ISCOJ Online Judge](http://iscoj.fg.tp.edu.tw/)
==

## Installation guide

### Direct installation

Make sure the current user has `sudo` privileges, and run the installation script:

```
curl -sSL https://raw.githubusercontent.com/TIOJ-INFOR-Online-Judge/tioj/main/scripts/install.sh | DB_PASSWORD=some_password bash -s
```

It is recommended to run this script on a freshly-installed machine. This script will install both the web server (by `passenger-install-nginx-module`) and the [judge client](https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge), and start & enable them via systemd.

The systemd service names are `nginx.service` and `tioj-judge.service`. The configuration files are located at `/opt/nginx/conf` and `/etc/tioj-judge.conf`. You can modify them and reload/restart the services.

If password recovery is needed, [setup the settings file](#settings) after the installation is completed, or pass the `SMTP_*` and `MAIL_*` environment variables to `bash` just like those in `.env.example`.

This script is tested on Ubuntu 20.04 LTS and 22.04 LTS. It also works on Arch Linux, but direct installation on Arch Linux is not recommended since it involves rebuilding some community packages for static libraries.

It is strongly recommended to mount tmpfs on `/tmp` by adding `tmpfs /tmp tmpfs rw,nosuid,nodev` in `/etc/fstab`.

### Docker

1. Install `docker-compose` and setup `.env` using the format of `.env.example`.
    - The `SMTP_*` and `MAIL_*` variables are only added if password recovery function is needed. Without them, the function is automatically disabled.
2. `docker-compose up -d` and enjoy TIOJ on port 4000.

### Settings

If password recovery and/or Sentry monitoring is needed, setup `config/settings.yml` using the format of `config/settings.yml.example`. The old method of using `rails credentials:edit` is deprecated.

## Judge Management

TIOJ has an admin control panel located at `/admin` (powered by [Active Admin](https://activeadmin.info/)), which has an independent authentication system. The default admin username and password are both `admin` (set in `db/seeds.rb` and created when running `rails db:seed`).

Though one can add/edit some settings through the control panel, it is not the recommended way to manage the judge (and it might lead to some errors). Instead, one should create an ordinary account, enter the `Users` tab in the control panel to set the account as an admin account, and use it to do all ordinary management such as problem setting, testdata uploading, and article creation.

It is possible to have multiple judge clients by setting up the fetch keys in the `Judge Servers` tab in the control panel.
