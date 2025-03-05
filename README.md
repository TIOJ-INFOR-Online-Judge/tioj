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

TIOJ is an online judge website. It is powered by [Ruby on Rails](https://rubyonrails.org/) and the [cjail](https://github.com/Leo1003/cjail)-based [tioj-judge](https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge) judge client.

Documentation is available in [Wiki](https://github.com/TIOJ-INFOR-Online-Judge/tioj/wiki).

## Get Started

See [Wiki](https://github.com/TIOJ-INFOR-Online-Judge/tioj/wiki/Get-Started) for instructions to install TIOJ.
