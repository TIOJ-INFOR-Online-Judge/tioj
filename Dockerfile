FROM ruby:3.1.2

RUN apt update
RUN apt install -y netcat rsync nodejs

ARG MYSQL_ROOT_PASSWORD
ENV PASSWORD=$MYSQL_ROOT_PASSWORD
ARG TIOJ_KEY
ENV TIOJ_KEY=$TIOJ_KEY

COPY Gemfile Gemfile.lock /tioj/
WORKDIR /tioj
RUN MAKEFLAGS='-j2' bundle install

COPY . /tioj

RUN echo "development:\n\
 adapter: mysql2\n\
 database: tioj_dev\n\
 host: db\n\
 username: root\n\
 password: $PASSWORD\n\
 encoding: utf8\n\
test:\n\
 adapter: mysql2\n\
 database: tioj_test\n\
 host: db\n\
 username: root\n\
 password: $PASSWORD\n\
 encoding: utf8\n\
production:\n\
 adapter: mysql2\n\
 database: tioj_production\n\
 host: db\n\
 username: root\n\
 password: $PASSWORD\n\
 encoding: utf8"\
> config/database.yml

RUN rails assets:precompile
RUN EDITOR=cat rails credentials:edit

# Move public/ to public-tmp/ since we're going to override it with 'volumes';
#  run_server moves it back
RUN mv public public-tmp

CMD ./run_server.sh 1
