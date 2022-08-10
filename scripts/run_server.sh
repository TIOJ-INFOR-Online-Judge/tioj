#!/usr/bin/env bash

set -e

if [ "$1" == "1" ]; then
  if [ -d public-tmp ]; then
    rsync -avh public-tmp/ public/
    rm -rf public-tmp
  fi
  until timeout 2s nc -z db 3306; do
    sleep 1
  done
  redis-server & disown
fi

if rails db:exists; then
  rails db:migrate
else
  rails db:setup
fi
/usr/local/bundle/bin/passenger start --port 4000
