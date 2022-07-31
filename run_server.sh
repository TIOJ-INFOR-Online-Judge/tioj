#!/usr/bin/env bash

if [ "$1" == "1" ]; then
  if [ -d public-tmp ]; then
    rsync -avh public-tmp/ public/
    rm -rf public-tmp
  fi
  until timeout 2s nc -z db 3306; do
    sleep 1
  done
fi

rails db:setup
/usr/local/bundle/bin/passenger start --port 4000
