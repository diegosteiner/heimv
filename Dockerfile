### === base === ###                 
FROM ruby:3.0.3-alpine AS base
RUN apk add --no-cache --update postgresql-dev tzdata nodejs
RUN adduser -D develop
RUN gem install bundler
# ENV PYTHON=/usr/bin/python3

### === development === ###                 
FROM base AS development
RUN apk add --update build-base \
    python3 \
    linux-headers \
    git \
    yarn \
    less \
    curl \
    gnupg \
    openssh-client

RUN gem install solargraph standardrb ruby-debug-ide debase rufo

ENV BUNDLE_CACHE_ALL=true
ENV BUNDLE_PATH=/home/develop/app/vendor/bundle
USER develop
WORKDIR /home/develop/app

### === build === ### 
FROM development AS build                                                      

#ENV RAILS_ENV=production               
#ENV NODE_ENV=production   
#ENV BUNDLE_WITHOUT="test:development"

COPY --chown=develop . /home/develop/app
RUN mkdir -p /home/develop/vendor/cache && \
    mkdir -p /home/develop/vendor/bundle && \
    mkdir -p /home/develop/node_modules

RUN bundle install && \
    bundle clean && \
    bundle package

RUN yarn install && \
    bin/webpack

### === production === ###
FROM base AS production

RUN adduser -D app && mkdir -p /app && chown -R app /app
USER app    
WORKDIR /app

ENV BUNDLE_WITHOUT="test:development"
ENV BUNDLE_DEPLOYMENT="true"
ENV BUNDLE_PATH=/app/vendor/bundle

COPY --chown=app --from=build /home/develop/app /app                              
RUN bundle install --local
RUN rm -rf /app/node_modules/* 

ENV RAILS_ENV=production               
ENV NODE_ENV=production 
ENV RAILS_LOG_TO_STDOUT="true"  
ENV PORT=3000

CMD ["bin/rails", "s", "-b", "0.0.0.0"] 
