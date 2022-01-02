FROM ruby:3.1.0-alpine3.15

ENV LANG C.UTF-8

RUN apk update && \
apk upgrade && \
apk add --update --no-cache build-base tzdata && \
gem install bundler -v 2.2.4
