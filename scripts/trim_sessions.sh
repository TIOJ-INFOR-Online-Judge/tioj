#!/usr/bin/env bash

if [ -f /etc/profile.d/rvm.sh ]; then
  source "/etc/profile.d/rvm.sh"
fi

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null
cd ..

RAILS_ENV=production SESSION_DAYS_TRIM_THRESHOLD=60 rails db:sessions:trim
