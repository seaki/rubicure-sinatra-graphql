FROM ruby:3.3.0-alpine3.19

ENV LANG C.UTF-8

RUN apk update && \
apk upgrade && \
apk add --update --no-cache build-base tzdata && \
gem install bundler -v 2.3.6
