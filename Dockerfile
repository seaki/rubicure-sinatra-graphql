FROM ruby:2.6.3-alpine3.9

ENV LANG C.UTF-8
ENV APP_ROOT /usr/src/rubicure-sinatra-graphql

RUN mkdir ${APP_ROOT}
WORKDIR ${APP_ROOT}

COPY Gemfile ${APP_ROOT}/Gemfile
COPY Gemfile.lock ${APP_ROOT}/Gemfile.lock

RUN apk update && \
apk upgrade && \
apk add --update --no-cache tzdata && \
bundle install -j4

COPY . ${APP_ROOT}

EXPOSE 4567
CMD ["ruby", "rubicure-sinatra-graphql.rb", "-o", "0.0.0.0"]
