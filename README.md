[TIOJ INFOR Online Judge](http://tioj.ck.tp.edu.tw/)
==

TIOJ is an online judge website. It is powered by [Ruby on Rails](https://rubyonrails.org/) and the [cjail](https://github.com/Leo1003/cjail)-based [tioj-judge](https://github.com/TIOJ-INFOR-Online-Judge/tioj-judge) judge client.

Documentation is available in [Wiki](https://github.com/TIOJ-INFOR-Online-Judge/tioj/wiki).

## Get Started

See [Wiki](https://github.com/TIOJ-INFOR-Online-Judge/tioj/wiki/Get-Started) for instructions to install TIOJ.

## Requirements

Ruby 3.2 or newer. See the setup guide in the Wiki for installation instructions.

## Development tools

Model annotations are managed by AnnotateRb using `.annotaterb.yml`.
Development database migrations update annotations automatically.

Run `bundle exec annotaterb models` to update annotations manually.
Set `ANNOTATERB_SKIP_ON_DB_TASKS=1` to skip automatic annotations.
