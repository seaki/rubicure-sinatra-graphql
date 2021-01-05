FROM ruby:2.4.10-alpine3.11

ENV LANG C.UTF-8

RUN apk update && \
apk upgrade && \
apk add --update --no-cache tzdata && \
gem install bundler -v 2.2.4
