FROM ruby:2.5.1-alpine
# FROM ruby:2.6.1-alpine
RUN apk add --no-cache --update build-base \
  linux-headers \
  git \
  postgresql-dev \
  nodejs \
  yarn \
  tzdata
RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY package.json yarn.lock /app/
RUN yarn install

COPY . /app
# RUN bin/webpack
# RUN /app/bin/setup
