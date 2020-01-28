FROM ruby:2.6.5-alpine AS base
RUN apk add --no-cache --update build-base \
  linux-headers \
  git \
  postgresql-dev \
  nodejs \
  yarn \
  less \
  tzdata
RUN mkdir -p /app
WORKDIR /app

ENTRYPOINT [ "/app/.docker/entrypoints/app.sh" ]

# === production ===
FROM base AS production

COPY Gemfile /app/
COPY Gemfile.lock /app/
ENV BUNDLE_PATH=/usr/local/bundle
RUN gem install bundler
RUN bundle install --without=development --without=test

COPY package.json /app/
COPY yarn.lock /app/
RUN yarn install

COPY . /app

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV WEBPACKER_PRECOMPILE=true

# RUN RAILS_ENV=production bundle exec rake assets:precompile
