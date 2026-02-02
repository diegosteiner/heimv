### === base === ###                 
FROM ruby:4.0.0-alpine AS base
RUN apk add --no-cache --update postgresql-dev yaml-dev tzdata nodejs npm git
RUN gem install bundler

WORKDIR /rails

# ENV BUNDLE_PATH="/usr/local/bundle"

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
    postgresql17-client \
    musl musl-utils musl-locales

USER rails:rails
ENV BINDING=0.0.0.0

### === test === ###                 
FROM development AS test

COPY --chown=rails:rails Gemfile Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile

COPY --chown=rails:rails package.json yarn.lock ./
RUN yarn install

COPY --chown=rails:rails . .

RUN bundle exec bootsnap precompile app/ lib/

### === build === ### 
FROM base AS build                                                      

RUN apk add --update build-base yarn

USER rails:rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development" \
    NODE_ENV="production" \
    APP_HOST="localhost"

COPY --chown=rails:rails Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY --chown=rails:rails package.json yarn.lock ./
RUN yarn install

COPY --chown=rails:rails . .
RUN bundle exec bootsnap precompile app/ lib/ && \
    bin/vite build

### === production === ###
FROM base AS production

EXPOSE 3000
CMD ["bin/rails", "s", "-b", "0.0.0.0"]

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

USER rails:rails

