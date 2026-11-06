FROM ubuntu:26.04

RUN apt update -y && apt upgrade -y
RUN apt install --no-install-recommends -y \
    build-essential curl rsync netcat-openbsd redis-server cron extrepo \
    libmysqlclient-dev imagemagick

RUN extrepo enable mise && apt update -y
RUN apt install -y mise
RUN mise use -g node@22 npm:yarn@1.22 ruby@4.0 gem:rubocop@1.92
ENV PATH="/root/.local/share/mise/shims:${PATH}"

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

# Move public/ to public-tmp/ since we're going to override it with 'volumes';
#  run_server moves it back
RUN mv public public-tmp

CMD /tioj/scripts/run_server.sh 1
