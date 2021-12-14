FROM ruby:2.7
MAINTAINER Meedan <sysops@meedan.com>

RUN apt-get update -qq && apt-get install -y --no-install-recommends curl build-essential libffi-dev dumb-init

WORKDIR /app

COPY Gemfile* ./
RUN gem install nokogiri -v 1.12.5
RUN bundle config set specific_platform true && bundle install
COPY . .

ENTRYPOINT ["/usr/bin/dumb-init", "--", "make"]
