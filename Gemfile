# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "graphql", "~> 1.9"
gem "rubicure", ">= 1.2.1"

# activesupport >= 6.0.0 requires ruby >= 2.5.0
gem "activesupport", "< 6.0.0"
gem "rack-contrib", "~> 2.1"
gem "sinatra", "~> 2.0"
gem "sinatra-contrib", "~> 2.0"
gem "slim", "~> 4.0"

group :test do
    gem "rack-test", "~> 1.1"
    gem "rspec", "~> 3.8"
    gem "timecop"
end
