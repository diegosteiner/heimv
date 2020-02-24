FROM ruby:2.7.0-alpine AS base

### === development === ###
FROM base AS development
RUN apk add --update build-base \
  linux-headers \
  git \
  postgresql-dev \
  nodejs \
  yarn \
  less \
  bash \
  curl \
  tzdata

RUN gem install bundler
ENV BUNDLE_PATH=/app/vendor

RUN mkdir -p /app
RUN adduser -D app --home /app
WORKDIR /app

### === build === ###
FROM development AS build

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV BUNDLE_PATH=/app/vendor

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --without=test --without=development --deployment

COPY package.json /app/
COPY yarn.lock /app/
RUN yarn install --frozen-lockfile

COPY . /app
RUN bin/webpack
RUN rm -rf /app/node_modules
RUN rm -rf /app/tmp
RUN rm -rf /app/.git

### === production === ###
FROM base AS production

RUN apk add --no-cache --update postgresql-dev tzdata

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV RAILS_LOG_TO_STDOUT="true"

COPY --from=build /app /app
RUN adduser -D app --home /app && chown -R app:app /app
WORKDIR /app

RUN bundle install --without=test --without=development --deployment

EXPOSE $PORT
USER app
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
