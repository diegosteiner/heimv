### === base === ###                 
FROM ruby:3.2.2-alpine AS base
RUN apk add --no-cache --update postgresql-dev tzdata libssl1.1 nodejs
RUN gem install bundler

### === development === ###                 
FROM base AS development
RUN apk add --update build-base \
    python3 \
    linux-headers \
    gcompat \
    git \
    yarn \
    less \
    curl \
    gnupg \
    openssh-client \
    musl musl-utils musl-locales

RUN gem install solargraph standardrb ruby-debug-ide debug rufo

ENV BUNDLE_CACHE_ALL=true
ENV BUNDLE_PATH=/home/develop/app/vendor/bundle
RUN adduser -D develop && \
    chown -R develop /home/develop
USER develop
RUN mkdir -p /home/develop/app
WORKDIR /home/develop/app

### === build === ### 
FROM development AS build                                                      

ENV RAILS_ENV=production               

COPY --chown=develop . /home/develop/app
RUN mkdir -p /home/develop/app/vendor/cache && \
    mkdir -p /home/develop/app/vendor/bundle && \
    mkdir -p /home/develop/app/node_modules

RUN bundle install && \
    bundle clean && \
    bundle package

RUN yarn install && \
    NODE_ENV=production bin/shakapacker

### === production === ###
FROM base AS production

RUN adduser -D app && mkdir -p /app && chown -R app /app
USER app    
WORKDIR /app

ENV BUNDLE_WITHOUT="test:development"
ENV BUNDLE_DEPLOYMENT="true"
ENV BUNDLE_PATH=/app/vendor/bundle
ENV RAILS_ENV=production               
ENV NODE_ENV=production 
ENV RAILS_LOG_TO_STDOUT="true"  
ENV PORT=3000

CMD ["bin/rails", "s", "-b", "0.0.0.0"] 

COPY --chown=app --from=build /home/develop/app /app                              
RUN bundle install --local
RUN rm -rf /app/node_modules/* 
