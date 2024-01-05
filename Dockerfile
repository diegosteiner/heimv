### === base === ###                 
FROM ruby:3.3.0-alpine AS base
RUN apk add --no-cache --update postgresql-dev tzdata nodejs npm
RUN gem install bundler

WORKDIR /rails

ENV BUNDLE_PATH="/usr/local/bundle"

RUN adduser -D rails && \
    chown -R rails:rails /rails /usr/local/bundle

### === development === ###                 
FROM base AS development
RUN apk add --update build-base \
    linux-headers \
    gcompat \
    git \
    yarn \
    less \
    curl \
    gnupg \
    openssh-client \
    musl musl-utils musl-locales

USER rails:rails

RUN gem install standardrb ruby-lsp

### === build === ### 
FROM base AS build                                                      

RUN apk add --update build-base

USER rails:rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .
RUN bundle exec bootsnap precompile app/ lib/

### === production === ###
FROM base AS production

EXPOSE 3000

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

USER rails:rails

