FROM ruby:2.7.1-alpine3.10

ENV LANG C.UTF-8

RUN apk update && \
apk upgrade && \
apk add --update --no-cache tzdata && \
gem install bundler -v 2.1.3
