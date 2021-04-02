FROM ruby:3.0.0-alpine3.12

ENV LANG C.UTF-8

RUN apk update && \
apk upgrade && \
apk add --update --no-cache build-base tzdata && \
gem install bundler -v 2.2.4
