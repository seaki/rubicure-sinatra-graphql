# rubicure-sinatra-graphql

[![RSpec](https://github.com/seaki/rubicure-sinatra-graphql/actions/workflows/rspec.yml/badge.svg?branch=ruby-3.0)](https://github.com/seaki/rubicure-sinatra-graphql/actions/workflows/rspec.yml?query=branch%3Aruby-3.0)

rubicure-sinatra-graphql is Precure, Japanese battle heroine "Pretty Cure (Precure)" GraphQL implementation based on Rubicure gem, simplified one.

## Requirements

* ruby 3.0 (see [Branches](#branches) for other Ruby versions)

* sinatra

* rubicure >= 3.2.2 (uses #members)

* Compose V2 (when deploy into container)

## Branches

Each supported Ruby version has its own branch. This is the `ruby-3.0` branch.

| Branch | Ruby |
| --- | --- |
| `master` | 4.0 |
| `ruby-3.4` | 3.4 |
| `ruby-3.3` | 3.3 |
| `ruby-3.2` | 3.2 |
| `ruby-3.1` | 3.1 |
| `ruby-3.0` | 3.0 |
| `ruby-2.7` | 2.7 |

The branches share the same application code. They differ in the Ruby version pinned in `Gemfile` and the Dockerfiles, and in `Gemfile.lock`, which holds the gem versions that work with that Ruby.

## How to run in Docker

```
$ docker compose build
$ docker compose up -d
```

## How to deploy

(T.B.D.)

## How to use

Call from your GraphQL client. Endpoint is located at '/graphql'.

## How to contribute

1. Fork this repo
2. Create your feature branch ( git checkout -b features_or_fix_or_chores_or_something/patch_name )
3. Fun with this code and commit your changes ( git commit -am "I have made some modifications" )
4. Push to your forked repo ( git push origin features_or_fix_or_chores_or_something/patch_name )
5. Create new pull request
