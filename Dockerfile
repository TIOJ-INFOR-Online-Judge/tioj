FROM ruby:3.3.7

RUN apt update && apt upgrade -y

# Yarn & nodejs setup
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt update -y
RUN apt install -y rsync netcat-openbsd nodejs yarn redis-server cron --no-install-recommends

ARG MYSQL_ROOT_PASSWORD
ENV PASSWORD=$MYSQL_ROOT_PASSWORD
ARG TIOJ_KEY
ENV TIOJ_KEY=$TIOJ_KEY

COPY Gemfile Gemfile.lock package.json yarn.lock /tioj/
WORKDIR /tioj
RUN echo '30 3 * * * /tioj/scripts/trim_sessions.sh' >> /etc/crontab
RUN MAKEFLAGS='-j2' bundle install
RUN yarn install --frozen-lockfile

COPY . /tioj

RUN echo "default: &default\n\
  adapter: mysql2\n\
  host: db\n\
  username: root\n\
  password: $PASSWORD\n\
  encoding: utf8mb4\n\
\n\
development:\n\
  <<: *default\n\
  database: tioj_dev\n\
test:\n\
  <<: *default\n\
  database: tioj_test\n\
production:\n\
  <<: *default\n\
  database: tioj_production"\
> config/database.yml

RUN EDITOR=true rails credentials:edit
RUN rails assets:precompile

# Move public/ to public-tmp/ since we're going to override it with 'volumes';
#  run_server moves it back
RUN mv public public-tmp

CMD /tioj/scripts/run_server.sh 1
