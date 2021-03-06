FROM ruby:2.7
MAINTAINER Meedan <sysops@meedan.com>

RUN apt-get update -qq && apt-get install -y --no-install-recommends curl build-essential libffi-dev dumb-init

WORKDIR /app

COPY Gemfile* ./
RUN bundle install
COPY . .

ENTRYPOINT ["/usr/bin/dumb-init", "--", "make"]
