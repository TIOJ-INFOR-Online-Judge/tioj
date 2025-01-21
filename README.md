TIOJ: NTUCPC variant
==

Modified from [IOICAMP Online Judge](https://github.com/ioicamp/tioj).

## features

目前 follow 上游 TIOJ v3.0.0，在 merge 過程順便把 NTUCPC judge 的 feature 重新整理一遍

### 與原版 TIOJ 不同的地方
大部分都是在 ioicamp judge 上實作的，可以從上面的 github 的 README 看到更多實作細節。
- 禁止註冊 \
    comment: 可以用環境變數 `ALLOW_REGISTER=allow` 來允許註冊。 \
    或者是用 `ALLOW_REGISTER=token_XXXXXXXXXXXXX` 讓擁有 token 的人才可以註冊。 \
    前端依然會把按鈕藏起來，要自己 POST request 包含一個欄位 `register_token`，
    其內容也一樣是 `token_XXXXXXXXXXXXX` 才允許註冊。
- 禁止刪除帳號
- 讓 admin 可以在計分板上看到名字
- ioicamp 的 contest type
- 要登入才能看題目 \
    comment: 這個 feature 好像只是用來防止有人沒把題目開成 invisible?
- `dashboard.json` 的 endpoint \
    comment: for 氣球機 discord bot \
    只有 admin 才能看
- visibility 為 contest 的題目在比賽中必須要 register 才能看得到 \
    comment: 比賽後的話本來就看不到，原版 TIOJ 則是比賽中外面的也能看得到題目。
- [X] roles 功能
    comment: 只要 user 跟 problem 有共同的 role，就能看到非公開的題目。 \
    主要是在比賽結束後把 ioicamp 學員放進 role，讓學員可以看到題目來補題，而防止其他人看到營隊題目。
- [X] About Page
- [X] favicon/banner
- [X] `config.site_name`

### 預計增加的功能
TODO

### 預計拔掉的功能
- [ ] 禁止註冊
- [ ] 禁止刪除帳號

[TIOJ INFOR Online Judge](http://tioj.ck.tp.edu.tw/)
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
