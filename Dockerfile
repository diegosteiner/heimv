### === base === ###
FROM ruby:2.7.0-alpine AS development
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

RUN mkdir -p /app
WORKDIR /app

### === build === ###
FROM development AS build

ENV RAILS_ENV=production
ENV NODE_ENV=production

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle config set deployment 'true'
RUN bundle install --without=test --without=development --deployment

COPY package.json /app/
COPY yarn.lock /app/
RUN yarn install

COPY . /app
RUN bin/webpack
RUN rm -rf /app/node_modules
RUN rm -rf /app/tmp
RUN rm -rf /app/.git

### === production === ###
FROM ruby:2.7.0-alpine AS production

RUN apk add --no-cache --update postgresql-dev tzdata

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV RAILS_LOG_TO_STDOUT="true"
RUN adduser -D app

COPY --from=build /app /app
RUN chown -R app:app /app

WORKDIR /app
RUN bundle config set deployment 'true'
RUN bundle install --without=test --without=development --deployment

USER app
EXPOSE $PORT
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
