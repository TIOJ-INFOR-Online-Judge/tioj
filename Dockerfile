FROM ruby:3.1.2

RUN apt update
RUN apt install -y netcat rsync nodejs redis-server

ARG MYSQL_ROOT_PASSWORD
ENV PASSWORD=$MYSQL_ROOT_PASSWORD
ARG TIOJ_KEY
ENV TIOJ_KEY=$TIOJ_KEY

COPY Gemfile Gemfile.lock /tioj/
WORKDIR /tioj
RUN MAKEFLAGS='-j2' bundle install

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
