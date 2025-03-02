#!/usr/bin/env bash

set -e

if [ "$1" == "1" ]; then
  # Initialize on the first run in the container
  if [ -d public-tmp ]; then
    # Move public files to the directory visible to host
    rsync -avh public-tmp/ public/
    rm -rf public-tmp

    # Create settings file from environment
    if [[ "${SMTP_USERNAME:-}" != "" && "${SMTP_PASSWORD:-}" != "" ]]; then
      cat <<EOF > config/settings.yml
shared:
  mail_settings:
    smtp_settings:
      address: ${SMTP_ADDRESS:-smtp.gmail.com}
      port: ${SMTP_PORT:-587}
      user_name: $SMTP_USERNAME
      password: $SMTP_PASSWORD
      enable_starttls_auto: true
    url_options:
      host: ${MAIL_HOSTNAME:-hostname}
    sender: ${MAIL_SENDER:-$SMTP_USERNAME}
EOF
    fi
  fi
  until timeout 2s nc -z db 3306; do
    sleep 1
  done
  redis-server & disown
  cron
fi

if rails db:exists; then
  rails db:migrate
else
  rails db:setup
fi
/usr/local/bundle/bin/passenger start --port 4000
