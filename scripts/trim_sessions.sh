#!/usr/bin/env bash

eval $(mise activate bash)

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null
cd ..

RAILS_ENV=production SESSION_DAYS_TRIM_THRESHOLD=60 rails db:sessions:trim
