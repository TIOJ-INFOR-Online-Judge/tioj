[TIOJ INFOR Online Judge](http://tioj.ck.tp.edu.tw/)
==

TIOJ is an online judge website. It is powered by [Ruby on Rails](https://rubyonrails.org/) and the [cjail](https://github.com/Leo1003/cjail)-based [tioj-judge](https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge) judge client.

Documentation is available in [Wiki](https://github.com/TIOJ-INFOR-Online-Judge/tioj/wiki).

## Get Started

See [Wiki](https://github.com/TIOJ-INFOR-Online-Judge/tioj/wiki/Get-Started) for instructions to install TIOJ.

The native installer targets Ubuntu 22.04, 24.04, and 26.04 LTS with the following dependency setup:

| Ubuntu | GCC 15 | Python 2.7.18 | Static OpenSSL dependency |
| --- | --- | --- | --- |
| 22.04 | Toolchain PPA | Ubuntu package | No extra entropy library |
| 24.04 | Toolchain PPA | Checksum-verified source build under `/usr/local` | No extra entropy library |
| 26.04 | Ubuntu repository | Checksum-verified source build under `/usr/local` | `libjitterentropy3-dev` |

The entropy library is required by Ubuntu 26.04's static OpenSSL build. It is unavailable and unnecessary on 22.04 and 24.04. MySQL accounts use `caching_sha2_password`, which works with both MySQL 8.0 and 8.4.
