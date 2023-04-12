FROM ruby:3.1.2

RUN apt update && apt upgrade -y

# Yarn & nodejs setup
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash -
RUN apt install -y rsync netcat nodejs yarn redis-server --no-install-recommends

ARG MYSQL_ROOT_PASSWORD
ENV PASSWORD=$MYSQL_ROOT_PASSWORD
ARG TIOJ_KEY
ENV TIOJ_KEY=$TIOJ_KEY

COPY Gemfile Gemfile.lock package.json yarn.lock /tioj/
WORKDIR /tioj
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
