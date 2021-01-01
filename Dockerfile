FROM ruby:3.0.0-alpine3.12

ENV LANG C.UTF-8
ENV APP_ROOT /usr/src/rubicure-sinatra-graphql

RUN mkdir ${APP_ROOT}
WORKDIR ${APP_ROOT}

COPY Gemfile ${APP_ROOT}/Gemfile
COPY Gemfile.lock ${APP_ROOT}/Gemfile.lock

RUN apk update && \
apk upgrade && \
apk add --update --no-cache tzdata && \
gem install bundler -v 2.1.3 && \
bundle install -j4

COPY . ${APP_ROOT}

EXPOSE 4567
CMD ["ruby", "app.rb", "-o", "0.0.0.0"]
