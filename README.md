TIOJ: IOIC variant
==

## features

因為 TIOJ 升級到 v2，在 merge 的途中順便把 ioicamp judge 的 feature 重新整理一遍（大部分 code 都是從舊的 commit 抓來的）

https://github.com/ioicamp/tioj/pulls

### 共同需求

- [X] 禁止註冊 [PR#24](https://github.com/ioicamp/tioj/commit/f9a13ec740d1f16791162338332f928ae312fba8) [PR#29](https://github.com/ioicamp/tioj/commit/effec6456dd36c6f976cccb52a25a277573951b3) \
    comment: 可以用環境變數 `ALLOW_REGISTER=allow` 來允許註冊。 \
    或者是用 `ALLOW_REGISTER=token_XXXXXXXXXXXXX` 讓擁有 token 的人才可以註冊。 \
    前端依然會把按鈕藏起來，要自己 POST request 包含一個欄位 `register_token`，
    其內容也一樣是 `token_XXXXXXXXXXXXX` 才允許註冊。
- [X] 禁止刪除帳號 [PR#25](https://github.com/ioicamp/tioj/commit/979e37bbcdba854c39aebc0c54ab53702c6d526b)
- [X] 讓 admin 可以在記分板上看到名字 [PR#27](https://github.com/ioicamp/tioj/commit/6efa6fba7b249a9c808a66ff87a0e1f4b6599d97)
- [X] 要登入才能看題目 [PR#26](https://github.com/ioicamp/tioj/commit/6916bcb879097255e3cd5183f90ceab2bd1c3515) \
    comment: 這個 feature 好像只是用來防止有人沒把題目開成 invisible?
- [X] IOIC type 的 contest（IOI type 和 ACM type 的混合） (PR#28)
- [X] user_whitelist（限制特定 regex 的人才能加進 contest） \
    comment: 好像本來就在 upstream 上
- [X] About page
- [ ] https://github.com/TIOJ-INFOR-Online-Judge/tioj/commit/a75130e74f3f628a8bb276587151f9e6d0d0aa23 \
    comment: 好像已經不存在 `.form-group > select` 的元素了(?)
- [ ] Translated verdict
- [X] Add dashboard.json endpoint (氣球機 discord bot)
- [X] Judge problem 的 contest visibility 的行為改成要比賽進行中且 user 為 register 才能看

### 每屆都會改的

- 換 banner, favicon
- 換 config.site_name

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
